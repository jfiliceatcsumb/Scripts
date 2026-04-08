#!/bin/bash
# =============================================================================
# blueprint_error_report.sh
#
# PURPOSE:
#   Identifies computers and mobile devices that have DDM declaration errors
#   for a specific Jamf Pro Blueprint. Queries the DDM status-items endpoint
#   for every managed device and filters for declarations tied to the given
#   blueprint ID that are not in a "valid" state.
#
# PREREQUISITES:
#   - macOS with bash/zsh, curl, and jq installed
#     Install jq via Homebrew: brew install jq
#   - A Jamf Pro API Client with the following privileges:
#       * Read Computers
#       * Read Mobile Devices
#       * Read Declarative Device Management
#   - OAuth 2.0 Client ID and Client Secret (never hardcode — use env vars or
#     a secrets manager)
#
# USAGE:
#   1. Set the required environment variables before running:
#        export JAMF_URL="https://yourserver.jamfcloud.com"
#        export JAMF_CLIENT_ID="your-client-id"
#        export JAMF_CLIENT_SECRET="your-client-secret"
#        export BLUEPRINT_ID="41f9fd2b-9278-4636-adf9-fd18a3485404"
#   2. Run the script:
#        bash blueprint_error_report.sh
#
# OUTPUT:
#   - Terminal summary of devices with blueprint declaration errors
#   - CSV report saved to: blueprint_errors_<BLUEPRINT_ID>.csv
#
# TESTING RECOMMENDATIONS:
#   - Test against a non-production Jamf Pro instance first
#   - Start with a small device scope to validate output before running
#     against your full fleet
#   - Review the CSV output before taking any remediation action
#
# RISKS:
#   - For large fleets, this script makes one API call per device. This may
#     take several minutes and generate significant API load.
#   - Rate limiting: Jamf Pro may throttle requests for very large fleets.
#     The script includes a small delay between requests to mitigate this.
#
# SECURITY NOTICE:
#   - This script is provided as a starting point only.
#   - Do NOT embed credentials directly in this script.
#   - Store CLIENT_ID and CLIENT_SECRET in environment variables or a
#     secrets manager.
#   - This script must NOT be deployed as a Jamf policy/client-side script.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration — set via environment variables (do NOT hardcode credentials)
# ---------------------------------------------------------------------------
JAMF_URL="${JAMF_URL:?ERROR: JAMF_URL environment variable is not set}"
CLIENT_ID="${JAMF_CLIENT_ID:?ERROR: JAMF_CLIENT_ID environment variable is not set}"
CLIENT_SECRET="${JAMF_CLIENT_SECRET:?ERROR: JAMF_CLIENT_SECRET environment variable is not set}"
BLUEPRINT_ID="${BLUEPRINT_ID:?ERROR: BLUEPRINT_ID environment variable is not set}"

# Output CSV file
OUTPUT_CSV="blueprint_errors_${BLUEPRINT_ID}.csv"

# Delay (in seconds) between per-device API calls to avoid rate limiting
REQUEST_DELAY=0.2

# ---------------------------------------------------------------------------
# Dependency check
# ---------------------------------------------------------------------------
if ! command -v jq &>/dev/null; then
    echo "ERROR: 'jq' is required but not installed."
    echo "Install it with: brew install jq"
    exit 1
fi

# ---------------------------------------------------------------------------
# Function: get_access_token
# Authenticates using OAuth 2.0 client_credentials grant and returns a token.
# ---------------------------------------------------------------------------
get_access_token() {
    local response
    response=$(curl --silent --fail \
        --request POST \
        --url "${JAMF_URL}/api/oauth/token" \
        --header "Content-Type: application/x-www-form-urlencoded" \
        --data-urlencode "grant_type=client_credentials" \
        --data-urlencode "client_id=${CLIENT_ID}" \
        --data-urlencode "client_secret=${CLIENT_SECRET}")

    local token
    token=$(echo "$response" | jq -r '.access_token // empty')

    if [[ -z "$token" ]]; then
        echo "ERROR: Failed to obtain access token. Check your CLIENT_ID and CLIENT_SECRET."
        exit 1
    fi

    echo "$token"
}

# ---------------------------------------------------------------------------
# Function: get_ddm_status_items
# Fetches DDM status items for a given clientManagementId.
# Returns the raw JSON response, or empty string on failure.
# ---------------------------------------------------------------------------
get_ddm_status_items() {
    local mgmt_id="$1"
    local token="$2"

    curl --silent \
        --request GET \
        --url "${JAMF_URL}/api/v1/ddm/${mgmt_id}/status-items" \
        --header "Authorization: Bearer ${token}" \
        --header "Accept: application/json" \
        --write-out "\n%{http_code}" \
        2>/dev/null
}

# ---------------------------------------------------------------------------
# Function: check_token_expiry
# Refreshes the token if it's been more than 25 minutes (tokens last 30 min).
# ---------------------------------------------------------------------------
TOKEN_OBTAINED_AT=0
ACCESS_TOKEN=""

refresh_token_if_needed() {
    local now
    now=$(date +%s)
    local elapsed=$(( now - TOKEN_OBTAINED_AT ))

    # Refresh if token is older than 25 minutes (1500 seconds)
    if [[ $elapsed -gt 1500 ]]; then
        echo "  [Auth] Refreshing access token..."
        ACCESS_TOKEN=$(get_access_token)
        TOKEN_OBTAINED_AT=$(date +%s)
    fi
}

# ---------------------------------------------------------------------------
# Main script
# ---------------------------------------------------------------------------
echo "============================================================"
echo "  Blueprint DDM Error Report"
echo "  Blueprint ID: ${BLUEPRINT_ID}"
echo "  Jamf Pro:     ${JAMF_URL}"
echo "============================================================"
echo ""

# Get initial access token
echo "[1/4] Authenticating with Jamf Pro..."
ACCESS_TOKEN=$(get_access_token)
TOKEN_OBTAINED_AT=$(date +%s)
echo "      Authentication successful."
echo ""

# ---------------------------------------------------------------------------
# Fetch all computers (paginated)
# ---------------------------------------------------------------------------
echo "[2/4] Fetching device inventory..."

declare -a DEVICES=()  # Array of "managementId|deviceName|serialNumber|deviceType"

PAGE=0
PAGE_SIZE=100

while true; do
    response=$(curl --silent --fail \
        --request GET \
        --url "${JAMF_URL}/api/v2/computers-inventory?page=${PAGE}&page-size=${PAGE_SIZE}&section=GENERAL" \
        --header "Authorization: Bearer ${ACCESS_TOKEN}" \
        --header "Accept: application/json")

    total=$(echo "$response" | jq -r '.totalCount // 0')
    count=$(echo "$response" | jq -r '.results | length')

    if [[ "$count" -eq 0 ]]; then
        break
    fi

    # Extract managementId, name, serialNumber for each computer
    while IFS= read -r entry; do
        DEVICES+=("$entry|computer")
    done < <(echo "$response" | jq -r '.results[] | "\(.general.managementId // "")|\(.general.name // "Unknown")|\(.general.serialNumber // "Unknown")"')

    PAGE=$(( PAGE + 1 ))
    fetched=$(( PAGE * PAGE_SIZE ))
    if [[ $fetched -ge $total ]]; then
        break
    fi
done

echo "      Found $(echo "${#DEVICES[@]}") computers."

# ---------------------------------------------------------------------------
# Fetch all mobile devices (paginated)
# ---------------------------------------------------------------------------
PAGE=0
MOBILE_COUNT=0

while true; do
    response=$(curl --silent --fail \
        --request GET \
        --url "${JAMF_URL}/api/v2/mobile-devices?page=${PAGE}&page-size=${PAGE_SIZE}" \
        --header "Authorization: Bearer ${ACCESS_TOKEN}" \
        --header "Accept: application/json")

    total=$(echo "$response" | jq -r '.totalCount // 0')
    count=$(echo "$response" | jq -r '.results | length')

    if [[ "$count" -eq 0 ]]; then
        break
    fi

    while IFS= read -r entry; do
        DEVICES+=("$entry|mobile")
        MOBILE_COUNT=$(( MOBILE_COUNT + 1 ))
    done < <(echo "$response" | jq -r '.results[] | "\(.managementId // "")|\(.displayName // "Unknown")|\(.serialNumber // "Unknown")"')

    PAGE=$(( PAGE + 1 ))
    fetched=$(( PAGE * PAGE_SIZE ))
    if [[ $fetched -ge $total ]]; then
        break
    fi
done

echo "      Found ${MOBILE_COUNT} mobile devices."
echo "      Total devices to check: ${#DEVICES[@]}"
echo ""

# ---------------------------------------------------------------------------
# Initialise CSV output
# ---------------------------------------------------------------------------
echo "DeviceName,SerialNumber,DeviceType,ManagementID,DeclarationIdentifier,ValidStatus,LastUpdated" > "$OUTPUT_CSV"

# ---------------------------------------------------------------------------
# Iterate over all devices and check DDM status items
# ---------------------------------------------------------------------------
echo "[3/4] Checking DDM status for each device (this may take a while)..."
echo ""

ERROR_COUNT=0
CHECKED=0
SKIPPED=0
TOTAL=${#DEVICES[@]}

for device_entry in "${DEVICES[@]}"; do
    # Parse the pipe-delimited entry
    IFS='|' read -r mgmt_id device_name serial_number device_type <<< "$device_entry"

    CHECKED=$(( CHECKED + 1 ))

    # Show progress every 25 devices
    if (( CHECKED % 25 == 0 )) || (( CHECKED == TOTAL )); then
        echo "  Progress: ${CHECKED}/${TOTAL} devices checked, ${ERROR_COUNT} errors found so far..."
    fi

    # Skip devices with no management ID (unmanaged)
    if [[ -z "$mgmt_id" || "$mgmt_id" == "null" ]]; then
        SKIPPED=$(( SKIPPED + 1 ))
        continue
    fi

    # Refresh token if needed
    refresh_token_if_needed

    # Query DDM status items for this device
    raw_response=$(get_ddm_status_items "$mgmt_id" "$ACCESS_TOKEN")
    http_code=$(echo "$raw_response" | tail -n1)
    body=$(echo "$raw_response" | head -n -1)

    # Skip devices that don't have DDM enabled (404) or other errors
    if [[ "$http_code" != "200" ]]; then
        SKIPPED=$(( SKIPPED + 1 ))
        sleep "$REQUEST_DELAY"
        continue
    fi

    # Parse status items and look for:
    #   1. Keys related to declarations (management.declarations.*)
    #   2. Values containing our blueprint ID
    #   3. Declaration entries where valid != "valid"
    #
    # The value field is a string like:
    # "{active=true, identifier=Blueprint_<ID>_..., valid=unknown, server-token=...}"
    # We parse each brace-delimited declaration entry from the value string.

    while IFS= read -r item; do
        key=$(echo "$item" | jq -r '.key // ""')
        value=$(echo "$item" | jq -r '.value // ""')
        last_updated=$(echo "$item" | jq -r '.lastUpdateTime // ""')

        # Only process declaration-related keys
        if [[ "$key" != management.declarations.* ]]; then
            continue
        fi

        # Check if this item references our blueprint
        if [[ "$value" != *"$BLUEPRINT_ID"* ]]; then
            continue
        fi

        # Split the value string into individual declaration entries
        # Each entry is wrapped in { } — extract them one at a time
        while IFS= read -r declaration; do
            # Extract the identifier and valid fields from each declaration entry
            identifier=$(echo "$declaration" | grep -oE 'identifier=[^,}]+' | cut -d= -f2 | xargs)
            valid_status=$(echo "$declaration" | grep -oE 'valid=[^,}]+' | cut -d= -f2 | xargs)

            # Skip if valid or empty
            if [[ -z "$valid_status" || "$valid_status" == "valid" ]]; then
                continue
            fi

            # Record the error
            ERROR_COUNT=$(( ERROR_COUNT + 1 ))
            echo "  ⚠️  ERROR: ${device_name} (${serial_number}) — ${identifier} [${valid_status}]"

            # Escape fields for CSV (wrap in quotes, escape internal quotes)
            csv_name=$(echo "$device_name" | sed 's/"/""/g')
            csv_serial=$(echo "$serial_number" | sed 's/"/""/g')
            csv_identifier=$(echo "$identifier" | sed 's/"/""/g')
            csv_valid=$(echo "$valid_status" | sed 's/"/""/g')
            csv_updated=$(echo "$last_updated" | sed 's/"/""/g')

            echo "\"${csv_name}\",\"${csv_serial}\",\"${device_type}\",\"${mgmt_id}\",\"${csv_identifier}\",\"${csv_valid}\",\"${csv_updated}\"" >> "$OUTPUT_CSV"

        done < <(echo "$value" | grep -oE '\{[^}]+\}')

    done < <(echo "$body" | jq -c '.statusItems[]? // empty')

    sleep "$REQUEST_DELAY"
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "============================================================"
echo "[4/4] Report Complete"
echo "============================================================"
echo "  Total devices checked : ${CHECKED}"
echo "  Devices skipped       : ${SKIPPED} (no DDM or no management ID)"
echo "  Declaration errors    : ${ERROR_COUNT}"
echo ""

if [[ $ERROR_COUNT -gt 0 ]]; then
    echo "  CSV report saved to: ${OUTPUT_CSV}"
    echo ""
    echo "  Devices with errors:"
    # Print a quick summary table from the CSV (skip header)
    tail -n +2 "$OUTPUT_CSV" | awk -F'","' '{printf "  %-30s %-15s %-10s %s\n", $1, $2, $3, $6}' | sed 's/"//g'
else
    echo "  No declaration errors found for blueprint ${BLUEPRINT_ID}."
    rm -f "$OUTPUT_CSV"
fi

echo ""
echo "Done."