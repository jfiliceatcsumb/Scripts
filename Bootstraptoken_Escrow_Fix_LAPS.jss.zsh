#!/bin/zsh --no-rcs

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Run it with 6 arguments.:

# PARAMETER 4: url
# PARAMETER 5: API client id
# PARAMETER 6: API client secret
# PARAMETER 7: jamfProID_ManagedPrefDomain
# PARAMETER 8: computerLocalAdminUsername
# PARAMETER 9: LAPSpasswordFallback
#  
# Use as script in Jamf JSS.
#

SCRIPTNAME=$(/usr/bin/basename "$0")
SCRIPTDIR=$(/usr/bin/dirname "$0")

# Jamf JSS Parameters 1 through 3 are predefined as mount point, computer name, and username

pathToScript=$0
if [[ -n "${1}" ]]; then
    mountPoint="${1}"
fi
if [[ -n "${2}" ]]; then
    computerName="${2}"
fi
if [[ -n "${3}" ]]; then
    userName="${3}"
fi

echo "pathToScript=$pathToScript"
echo "mountPoint=$mountPoint"
echo "computerName=$computerName"
echo "userName=$userName"

url=${4:=""}
client_id=${5:=""}
client_secret=${6:=""}
jamfProID_ManagedPrefDomain=${7:=""}
computerLocalAdminUsername=${8:=""}
LAPSpasswordFallback=${9:=""}


# ##### Debugging flags #####
# debug script by enabling verbose “-v” option
# set -v
# debug script using noexec (Test for syntaxt errors)
# set -n
# identify the unset variables while debugging script
# set -u
# debug script using xtrace
# set -x
# Enable tracing without trace output
# { set -x; } 2>/dev/null
# Disable tracing without trace output
# { set +x; } 2>/dev/null


# Token state
ACCESS_TOKEN=""
TOKEN_EXPIRATION_EPOCH=0

# ########## FUNCTIONS ##########


function getAccessToken() {
    local response
	response=$(curl --silent --location --request POST "${url}/api/oauth/token" \
 	 	--header "Content-Type: application/x-www-form-urlencoded" \
 		--data-urlencode "client_id=${client_id}" \
 		--data-urlencode "grant_type=client_credentials" \
 		--data-urlencode "client_secret=${client_secret}")
    # Try to extract access_token and expires_in
    ACCESS_TOKEN=$(echo "$response" | /usr/bin/plutil -extract access_token raw - 2>/dev/null || echo "")
    token_expires_in=$(echo "$response" | /usr/bin/plutil -extract expires_in raw - 2>/dev/null || echo "")
    # Fallback parsing if plutil failed (attempt simple grep/awk)
    if [[ -z "$ACCESS_TOKEN" ]]; then
        ACCESS_TOKEN=$(echo "$response" | /usr/bin/awk -F'"' '/access_token/{print $4; exit}')
    fi
    if [[ -z "$token_expires_in" ]]; then
        token_expires_in=$(echo "$response" | /usr/bin/awk -F'"' '/expires_in/{print $4; exit}')
    fi
    if [[ -z "$ACCESS_TOKEN" || -z "$token_expires_in" ]]; then
        echo "Failed to obtain access token." >&2
        return 1
    fi
    current_epoch=$(date +%s)
    TOKEN_EXPIRATION_EPOCH=$((current_epoch + token_expires_in - 1))
    return 0
}

function checkTokenExpiration() {
 	current_epoch=$(date +%s)
    if [[ ${TOKEN_EXPIRATION_EPOCH} -gt ${current_epoch} && -n "${ACCESS_TOKEN}" ]]; then
        echo "Token valid until epoch: ${TOKEN_EXPIRATION_EPOCH}"
    else
        echo "No valid token available (or expired), getting new token"
        getAccessToken
    fi
}

function invalidateToken() {
    if [[ -z "${ACCESS_TOKEN}" ]]; then
        echo "No token to invalidate"
        return 0
    fi
    responseCode=$(curl -w "%{http_code}" -H "Authorization: Bearer ${ACCESS_TOKEN}" "${url}/api/v1/auth/invalidate-token" -X POST -s -o /dev/null)
    if [[ ${responseCode} == 204 ]]; then
		echo "Token successfully invalidated"
        ACCESS_TOKEN=""
        TOKEN_EXPIRATION_EPOCH=0
    elif [[ ${responseCode} == 401 ]]; then
		echo "Token already invalid"
	else
        echo "An unknown error occurred invalidating the token: HTTP ${responseCode}"
	fi
}


function checkResponseCode()	{
    # arg is a concatenation of body and three-digit http code appended by curl
    local full="$1"
    local http="${full: -3}"
    case "${http}" in
        200) echo "200 Request successful";;
        201) echo "201 Request to create or update object successful";;
        400) echo "400 Bad request";;
        401) echo "401 Authentication failed";;
        403) echo "403 Invalid permissions";;
        404) echo "404 Object/resource not found";;
        409) echo "409 Conflict";;
        500) echo "500 Internal server error";;
        000) echo "000 No HTTP code received";;
        *) echo "${http} Unknown HTTP code";;
    esac
}


function apiGET()	{
    # usage: apiGET "Header-Name: value" "https://..."
    local extraHeader="$1"
    local urlToGet="$2"

			checkTokenExpiration
  

    # Get response body and HTTP code appended
    local apiGetResponse
	apiGetResponse=$( /usr/bin/curl \
        --header "Authorization: Bearer ${ACCESS_TOKEN}" \
        --header "${extraHeader}" \
	--request GET \
	--silent \
        --url "${urlToGet}" \
	--write-out "%{http_code}" )
	
    local codeCheck
    codeCheck=$( checkResponseCode "${apiGetResponse}" )
	
    # if first char of http code is 2 => success
    local httpCode="${apiGetResponse: -3}"
    if [[ "${httpCode:0:1}" != "2" ]]; then
        echo "Error while attempting to retrieve: ${codeCheck}" >&2
        return 1
	else
        # return body (strip last 3 chars)
        echo "${apiGetResponse:: -3}"
	fi
}

function setLAPSpassword() {
	for managementID in "${managementIDs[@]}"; do
		echo "Running simpleLAPS for management ID: $managementID"
		local accountName=$1
		checkTokenExpiration
  

		curl -X 'PUT' \
		"$url/api/v2/local-admin-password/$managementID/set-password" \
		--header 'accept: application/json' \
		--header "Authorization: Bearer ${ACCESS_TOKEN}" \
		--header 'Content-Type: application/json' \
		-d '{
	"lapsUserPasswordList": [
		{
			"username": "'$accountName'",
			"password": "Strong-ish_Password"
		}
	]
}'
		echo -e
	done	
	
}

function GETcomputerManagementID() {
	
	echo "Requesting oauth token."
	# Get bearer token for API transactions
	checkTokenExpiration || { echo "Unable to obtain token"; exit 1; }
	
	# Get local s/n
	readonly serialNumber=$( /usr/sbin/system_profiler SPHardwareDataType 2>/dev/null | /usr/bin/awk -F": " '/Serial Number/{ print $2 }' )
	echo "Computer serial number: $serialNumber"

	# get computer Jamf Pro ID from local plist (if present)
	jamfProComputerID=""
	if [[ -f "/Library/Managed Preferences/${jamfProID_ManagedPrefDomain}.plist" ]]; then
			jamfProComputerID=$(/usr/bin/defaults read "/Library/Managed Preferences/${jamfProID_ManagedPrefDomain}.plist" JamfProID 2>/dev/null || echo "")
	fi
	
	if [[ -z "${jamfProComputerID}" ]]; then
			# fallback to API (note: older JSS endpoints)
			computerGeneralXML=$( apiGET "Accept: text/xml" "${url}/JSSResource/computers/serialnumber/${serialNumber}" ) || { echo "Failed to fetch computer by serial"; exit 1; }
		jamfProComputerID=$( /usr/bin/xpath -e "/computer/general/id/text()" 2>/dev/null <<< "$computerGeneralXML" )
	# /api/v2/computers-inventory?section=GENERAL&filter=hardware.serialNumber%3D%3D${serialNumber}
	fi
	
	echo "jamfProComputerID: $jamfProComputerID"
	
	# get computer management ID (using v2 inventory)
	computerGeneralJson=$( apiGET "Accept: application/json" "${url}/api/v2/computers-inventory/${jamfProComputerID}?section=GENERAL" ) || { echo "Failed to fetch computer inventory"; exit 1; }
	
	computerManagementID=$( /usr/bin/awk -F "\"" '/managementId/{ print $4; exit }' <<< "$computerGeneralJson" )
	
	echo "Jamf Pro management ID: $computerManagementID"
	
	return 0

}

function GetLAPSpassword() {
		local computerLocalAdminUsername=$1
		LAPSpassword=""
		checkTokenExpiration
    if [[ -z ${computerManagementID} ]]; then
    	GETcomputerManagementID
    fi
    # get computer local admin password
# API get LAPS password
# /v2/local-admin-password/{clientManagementId}/account/{username}/password

		# LAPSpasswordJson=$( apiGET "Accept: application/json" "${url}/api/v2/local-admin-password/${computerManagementID}/account/${computerLocalAdminUsername}/password" ) || { echo "Failed to get password"; exit 1; }
		LAPSpasswordJson=$( apiGET "Accept: application/json" "${url}/api/v2/local-admin-password/${computerManagementID}/account/${computerLocalAdminUsername}/password" ) \
		&& LAPSpassword=$( /usr/bin/awk -F "\"" '/password/{ print $4; exit }' <<< "$LAPSpasswordJson" ) \
		|| { echo "Failed to get password"; echo "Using fallback static password"; LAPSpassword="${LAPSpasswordFallback}"; }
		
}


function GetLAPSusernames() {
	# get computer local admin username list
	
	checkTokenExpiration

	if [[ -z ${computerManagementID} ]]; then
		GETcomputerManagementID
	fi
	
	computerLocalAdminUsernameJson=$( apiGET "Accept: application/json" "${url}/api/v2/local-admin-password/${computerManagementID}/accounts" ) || { echo "Failed to get accounts"; exit 1; }
	
	computerLAPSUSERNAMES=$( /usr/bin/awk -F "\"" '/username/{ print $4 }' <<< "$computerLocalAdminUsernameJson" )
	echo "LAPS username(s):"
	echo "$computerLAPSUSERNAMES"

}

# ########## END FUNCTIONS ##########

# Add parameter validation
if [[ -z "${computerLocalAdminUsername}" ]] ; then
    echo "Error: LAPS account is required"
    exit 1
fi

GetLAPSpassword "${computerLocalAdminUsername}"

# Do not echo sensitive info in logs in production. These are printed here for debugging only.
echo "LAPS user name: ${computerLocalAdminUsername}"
echo "LAPS LAPSpassword: (redacted)"


# Add parameter validation
if [[ -z "${computerLocalAdminUsername}" ]] || [[ -z "${LAPSpassword}" ]]; then
    echo "Error: Volume owner account and password are required"
    exit 1
fi


# Show secure token status for additional info 
/usr/sbin/sysadminctl -secureTokenStatus  "${computerLocalAdminUsername}"
echo "Check Bootstrap Token status..."
bootstrap=$(/usr/bin/profiles status -type bootstraptoken)
echo ${bootstrap}
if [[ $bootstrap == *"supported on server: YES"* ]]; then
    if [[ $bootstrap == *"escrowed to server: YES"* ]]; then
		echo "Bootstrap escrowed. Exit script."
    else
		echo "Bootstrap not escrowed."
		echo "Creating the Bootstrap Token APFS record and escrowing to the MDM server..."
# 		Used to verify the password
# 		authenticate the account without actually logging into anything
# 		account authenticates in any way it will have a SecureToken enabled on the account
		if ! /usr/bin/dscl . authonly "${computerLocalAdminUsername}" "${LAPSpassword}"; then
			echo "Error: Authentication failed"
			exit 1
		fi
		sleep 1
		# Add error handling for profiles command
		if ! /usr/bin/profiles install -type bootstraptoken -user "${computerLocalAdminUsername}" -password "${LAPSpassword}" -verbose; then
			echo "Error: Failed to install bootstrap token"
			exit 1
		fi
		sleep 1	
		/usr/bin/profiles status -type bootstraptoken
  fi
else
	echo "Bootstrap token not supported on server"
	result="NOT SUPPORTED"
fi

exit 0
