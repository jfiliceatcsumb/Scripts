#!/bin/bash

# Installing Live in a Multi-User Environment (without Sassafras)
# https://help.ableton.com/hc/en-us/articles/209073209-Installing-Live-in-a-Multi-User-Environment-without-Sassafras-

# Set the following variables passed to script
# 
# Set the following to match the Live executable you are using:
#
EDITION="Ableton Live 11 Suite"
VERSION="11.1.6"

# ##### Debugging flags #####
# debug bash script by enabling verbose “-v” option
# set -v
# debug bash script using noexec (Test for syntaxt errors)
# set -n
# identify the unset variables while debugging bash script
set -u
# debug bash script using xtrace
# set -x

#
if [[ -n "$4" ]]; then
	EDITION="$4"
fi

# Set version number programmatically from app.
ShortVersionString=$(defaults read "/Applications/${EDITION}.app/Contents/Info.plist" CFBundleShortVersionString | awk '{print $1}' 2>/dev/null)

if [[ -n "$5" ]]; then
	VERSION="$5"
elif [[ -n "$ShortVersionString" ]]; then
	VERSION="$ShortVersionString"
fi

echo \"${EDITION}\"

echo \"${VERSION}\"

#

pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3

echo "pathToScript=$pathToScript"
echo "mountPoint=$mountPoint"
echo "computerName=$computerName"
echo "userName=$userName"

# 2.2.2 Create the Shared Unlock Folder
/bin/mkdir -p -m 755 "/Library/Application Support/Ableton/Live ${VERSION}/Unlock/"

# 2.2.3 Paste the Master Unlock.cfg file into the shared Unlock folder that you created in the step above.
# 
# Now, delete the Unlock folder in the default location. 
# /Users/$USER/Library/Application Support/Ableton/Live ${VERSION}/Unlock/
# /Users/admin/Library/Application Support/Ableton/Live 11.1.6/Unlock/

# 2.2.4 Shared Preferences and Options.txt
# 6.2 Example Options.txt

# https://help.ableton.com/hc/en-us/articles/6003224107292-Options-txt-file
# This will also force Live to use this Options.txt file, in case the current user has Options.txt files
# from previous versions in their home directory.
/bin/mkdir -p "/Library/Preferences/Ableton/Live ${VERSION}/"
LIVE_OPTIONS="/Library/Preferences/Ableton/Live ${VERSION}/Options.txt"
/usr/bin/touch "${LIVE_OPTIONS}"
echo "-_DisableAutoUpdates" > "${LIVE_OPTIONS}"
echo "-DontAskForAdminRights" >> "${LIVE_OPTIONS}"
echo "-_DisableUsageData" >> "${LIVE_OPTIONS}"

# 4. Cache/ Database
echo "-DefaultsBaseFolder=/tmp/AbletonData/%%USERNAME%%/" >> "${LIVE_OPTIONS}"
echo "-DatabaseDirectory=/Users/Shared/Ableton/Database/%%USERNAME%%/"  >> "${LIVE_OPTIONS}"

/bin/mkdir -p "/Users/Shared/Ableton/Database"
/bin/mkdir -p "/Users/Shared/Ableton/Factory Packs"
# set permissions

/bin/chmod 644 "${LIVE_OPTIONS}"

/bin/chmod 1777 "/Users/Shared/Ableton/Database"
/bin/chmod 1777 "/Users/Shared/Ableton/Factory Packs"

/usr/sbin/chown -fR root:wheel "/Users/Shared/Ableton/Database"
/usr/sbin/chown -fR root:wheel "/Users/Shared/Ableton/Factory Packs"



# 3.2 Ableton Live Packs
# admin group write access so the move operation works.
# mkdir -p -m 775 "/Library/Application Support/Ableton/Factory Packs/"


# /Users/admin/Music/Ableton/
# Factory Packs
# Live Recordings
# User Library

# Move the file titled Library.cfg (found in the user preferences) to the shared preferences folder (see 2.2.5). 
# This way, information about the Ableton Live Packs you just installed will automatically be available to all users.
# /Users/$USER/Library/Preferences/Ableton/Live ${VERSION}/
# /Users/admin/Library/Preferences/Ableton/Live 11.1.6/
# (Library.cfg, Options.txt, Log.txt)

# /Library/Preferences/Ableton/Live ${VERSION}/Library.cfg
# 				<ProjectPath Value="/Users/admin/Music/Ableton" />
# to
# 				<ProjectPath Value="/Users/%%USERNAME%%/Music/Ableton" />


