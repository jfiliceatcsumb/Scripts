#!/bin/bash

#
#
# Set the following to match the Live executable you are using:
#
#
EDITION="Ableton Live 12 Suite"
VERSION="12.0.20"

#
#
# Set the following to match your multi-seat token displayed at https://www.ableton.com/account.
# Make sure to select the correct multi-seat license in the license chooser.
# If you haven't yet generated a token, you can create a new one by clicking "Generate new token".
# The token will not expire until you revoke it by generating a new one. Revoke it if you suspect
# the token has been compromised and are observing unexpected Live authorizations.
#
# Note: The currently valid token is only used by Ableton Live during the authorization step below.
# Revoking it prevents new installations of Ableton Live from being authorized with the revoked
# token, but will not prevent existing, already authorized installations from running.
#
#
TOKEN="your authorization token here"

#
#
# During authorization, Live writes to a log file called Log.txt. This file can contain
# useful information to diagnose issues during authorization. If this script runs as
# an administrator, it may be preferrable to write this logfile somewhere else.
# Leave empty to use the default location.
#
#
LOGFILESDIR="/tmp/AbletonLogFiles"

# --- No further configuration below this line. ----------------------------------------------------

# Create shared Unlock folder
mkdir -p "/Library/Application Support/Ableton/Live ${VERSION}/Unlock/"
touch "/Library/Application Support/Ableton/Live ${VERSION}/Unlock/Unlock.json"
rm -f "/Library/Application Support/Ableton/Live ${VERSION}/Unlock/Unlock.cfg" 2>/dev/null

mkdir -p "/Library/Preferences/Ableton/Live ${VERSION}/"

# This will also force Live to use this Options.txt file, in case the current user has Options.txt files
# from previous versions in their home directory.
LIVEDEBUGOPTIONS="/Library/Preferences/Ableton/Live ${VERSION}/Options.txt"
echo "-_DisableAutoUpdates" > "${LIVEDEBUGOPTIONS}"
echo "-NoRestoreDocumentDialog" >> "${LIVEDEBUGOPTIONS}"
echo "-DontLoadMaxForLiveAtStartup" >> "${LIVEDEBUGOPTIONS}"

if [ -n "${LOGFILESDIR}" ]; then
    echo "-LogFilesDir=${LOGFILESDIR}" >> "${LIVEDEBUGOPTIONS}"
fi

# Copy Live application to /Applications for all users (macOS equivalent of Start Menu)
cp -f "/Applications/${EDITION}.app" "/Applications/" 2>/dev/null

# Create the log files directory
if [ -n "${LOGFILESDIR}" ]; then
    mkdir -p "${LOGFILESDIR}" 2>/dev/null
fi

# Run Ableton and capture its exit code
"/Applications/${EDITION}.app/Contents/MacOS/Live" --authorization-token="${TOKEN}"

# Capture the exit code
LIVE_EXIT_CODE=$?

# Rewrite Options.txt for subsequent runs
echo "-_DisableAutoUpdates" > "${LIVEDEBUGOPTIONS}"

# Check the exit code
if [ ${LIVE_EXIT_CODE} -ne 0 ]; then
    echo "Ableton ${EDITION} authorization failed with exit code ${LIVE_EXIT_CODE}"
    exit ${LIVE_EXIT_CODE}
else
    echo "Ableton ${EDITION} was successfully authorized."
    exit 0
fi
