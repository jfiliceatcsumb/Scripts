#!/bin/bash


# Set the following variables passed to script
# 
# Set the following to match the Live executable you are using:
#
#04
EDITION="Ableton Live 12 Suite" 
#05
VERSION="12.1"							
#06
TOKEN="your authorization token here"	
#07
LOGFILESDIR="/var/log/AbletonLogFiles"	
#08
RUNAS_UID=""							
#09
RUNAS_USER=""							

# --- No further configuration below this line. ----------------------------------------------------

# ##### Debugging flags #####
# debug bash script by enabling verbose “-v” option
# set -v
# debug bash script using noexec (Test for syntaxt errors)
# set -n
# identify the unset variables while debugging bash script
set -u
# debug bash script using xtrace
# set -x
# Enable tracing without trace output
# { set -x; } 2>/dev/null
# Disable tracing without trace output
# { set +x; } 2>/dev/null

#
if [[ -n "$4" ]]; then
	EDITION="$4"
fi

ShortVersionString=$(defaults read "/Applications/${EDITION}.app/Contents/Info.plist" CFBundleShortVersionString | awk '{print $1}' 2>/dev/null)
if [[ -n "$5" ]]; then
	VERSION="$5"
elif [[ -n "$ShortVersionString" ]]; then
	VERSION="$ShortVersionString"
fi

#
if [[ -n "$6" ]]; then
	TOKEN="$6"
fi

#
if [[ -n "$7" ]]; then
	LOGFILESDIR="$7"
fi

if [[ -n "$8" ]]; then
	RUNAS_UID="#${8}"
	SUDO_USER="${RUNAS_UID}"
elif [[ -n "${9}" ]]; then
	RUNAS_USER="${9}"
	SUDO_USER="${RUNAS_USER}"
else
	SUDO_USER="#501"
fi

echo \'${EDITION}\'

echo \'${VERSION}\'

echo \'${RUNAS_UID}\'

echo \'${RUNAS_USER}\'

echo \'${SUDO_USER}\'


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
#
#
#
# During authorization, Live writes to a log file called Log.txt. This file can contain
# useful information to diagnose issues during authorization. If this script runs as
# an administrator, it may be preferrable to write this logfile somewhere else.
# Leave empty to use the default location.
#


pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3

echo "pathToScript=$pathToScript"
echo "mountPoint=$mountPoint"
echo "computerName=$computerName"
echo "userName=$userName"
#


# Create shared Unlock folder
/bin/mkdir -p "/Library/Application Support/Ableton/Live ${VERSION}/Unlock/"
/usr/bin/touch "/Library/Application Support/Ableton/Live ${VERSION}/Unlock/Unlock.json"
/bin/rm -f "/Library/Application Support/Ableton/Live ${VERSION}/Unlock/Unlock.cfg" 2>/dev/null


# This will also force Live to use this Options.txt file, in case the current user has Options.txt files
# from previous versions in their home directory.
/bin/mkdir -p "/Library/Preferences/Ableton/Live ${VERSION}/"
LIVE_OPTIONS="/Library/Preferences/Ableton/Live ${VERSION}/Options.txt"
/usr/bin/touch "${LIVE_OPTIONS}"
echo "-_DisableAutoUpdates" > "${LIVE_OPTIONS}"
echo "-NoRestoreDocumentDialog" >> "${LIVE_OPTIONS}"
echo "-DontLoadMaxForLiveAtStartup" >> "${LIVE_OPTIONS}"
echo "-DontAskForAdminRights" >> "${LIVE_OPTIONS}"
echo "-_DisableUsageData" >> "${LIVE_OPTIONS}"

if [ -n "${LOGFILESDIR}" ]; then
    echo "-LogFilesDir=${LOGFILESDIR}" >> "${LIVE_OPTIONS}"
fi

# 4. Cache/ Database
echo "-DefaultsBaseFolder=/tmp/AbletonData/%%USERNAME%%/" >> "${LIVE_OPTIONS}"
echo "-DatabaseDirectory=/Users/Shared/Ableton/Database/%%USERNAME%%/"  >> "${LIVE_OPTIONS}"

# set permissions

chmod 644 "${LIVE_OPTIONS}"

# 3.2 Ableton Live Packs
# admin grou write access so the move operation works.
# mkdir -p -m 775 "/Library/Application Support/Ableton/Factory Packs/"


# /Users/admin/Music/Ableton/
# Factory Packs
# Live Recordings
# User Library

# Move the file titled Library.cfg (found in the user preferences) to the shared preferences folder (see 2.2.5). 
# This way, information about the Ableton Live Packs you just installed will automatically be available to all users.
# /Users/$USER/Library/Preferences/Ableton/Live $Version/
# /Users/admin/Library/Preferences/Ableton/Live 11.1.6/
# (Library.cfg, Options.txt, Log.txt)

# /Library/Preferences/Ableton/Live $Version/Library.cfg
# 				<ProjectPath Value="/Users/admin/Music/Ableton" />
# to
# 				<ProjectPath Value="/Users/%%USERNAME%%/Music/Ableton" />

# # Copy Live application to /Applications for all users (macOS equivalent of Start Menu)
# /bin/cp -f "/Applications/${EDITION}.app" "/Applications/" 2>/dev/null

# Create the log files directory
if [ -n "${LOGFILESDIR}" ]; then
    /bin/mkdir -p "${LOGFILESDIR}" 2>/dev/null
fi

# Run Ableton and capture its exit code

/usr/bin/sudo --user=${SUDO_USER} --login "/Applications/${EDITION}.app/Contents/MacOS/Live" --authorization-token="${TOKEN}" &

#/usr/bin/sudo --user=\#501 --login "/Applications/${EDITION}.app/Contents/MacOS/Live" --authorization-token="${TOKEN}" &

LIVE_PID=$!

# Loop while the process is found
echo "Waiting up to five minutes for completion, checking every 30 seconds..."
PROCESS_NAME="Live"
WHILE_COUNT1=0
# Loop while the process is found
while /usr/bin/pgrep -x "${PROCESS_NAME}" > /dev/null; do
	if [[ $WHILE_COUNT1 -lt 10 ]]; then
		((WHILE_COUNT1+=1))
		 # Sleep for 30 seconds before checking again
		 /bin/sleep 30
	else
# 		exit the loop if more than run more than 10 times (5 minutes)
		break
	fi
done
/bin/kill -KILL "$LIVE_PID" 2>/dev/null
# /usr/bin/killall -qv -TERM "${PROCESS_NAME}"

# Capture the exit code
LIVE_EXIT_CODE=$?

# Rewrite Options.txt for subsequent runs
echo "-_DisableAutoUpdates" > "${LIVE_OPTIONS}" 2>/dev/null

# Check the exit code
if [ ${LIVE_EXIT_CODE} -ne 0 ]; then
    echo "Ableton ${EDITION} authorization failed with exit code ${LIVE_EXIT_CODE}"
    exit ${LIVE_EXIT_CODE}
else
    echo "Ableton ${EDITION} was successfully authorized."
    exit 0
fi