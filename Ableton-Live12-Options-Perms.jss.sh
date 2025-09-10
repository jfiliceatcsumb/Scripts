#!/bin/bash


# Set the following variables passed to script
# 
# Set the following to match the Live executable you are using:
#
EDITION="Ableton Live 12 Suite"
VERSION="12.1"

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
#
#
#
# During authorization, Live writes to a log file called Log.txt. This file can contain
# useful information to diagnose issues during authorization. If this script runs as
# an administrator, it may be preferrable to write this logfile somewhere else.
# Leave empty to use the default location.
#
LOGFILESDIR="/var/log/AbletonLogFiles"
# 
#
if [[ -n "$6" ]]; then
	LOGFILESDIR="$6"
fi


pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3

echo "pathToScript=$pathToScript"
echo "mountPoint=$mountPoint"
echo "computerName=$computerName"
echo "userName=$userName"
#


# https://help.ableton.com/hc/en-us/articles/6003224107292-Options-txt-file
# This will also force Live to use this Options.txt file, in case the current user has Options.txt files
# from previous versions in their home directory.
/bin/mkdir -p "/Library/Preferences/Ableton/Live ${VERSION}/"
LIVE_OPTIONS="/Library/Preferences/Ableton/Live ${VERSION}/Options.txt"
/usr/bin/touch "${LIVE_OPTIONS}"
echo "-_DisableAutoUpdates" > "${LIVE_OPTIONS}"
echo "-DontAskForAdminRights" >> "${LIVE_OPTIONS}"
echo "-_DisableUsageData" >> "${LIVE_OPTIONS}"

if [ -n "${LOGFILESDIR}" ]; then
    echo "-LogFilesDir=${LOGFILESDIR}" >> "${LIVE_OPTIONS}"
fi

# 4. Cache/ Database
echo "-DefaultsBaseFolder=/tmp/AbletonData/%%USERNAME%%/" >> "${LIVE_OPTIONS}"
echo "-DatabaseDirectory=/Users/Shared/Ableton/Database/%%USERNAME%%/"  >> "${LIVE_OPTIONS}"

/bin/mkdir -p "/Users/Shared/Ableton/Database"
/bin/mkdir -p "/Users/Shared/Ableton/Factory Packs"
# set permissions

/bin/chmod 644 "${LIVE_OPTIONS}"

/bin/chmod 1777 "/Users/Shared/Ableton/Database"
/bin/chmod 1777 "/Users/Shared/Ableton/Factory Packs"

/usr/sbin/chown -fR 0:0 "/Users/Shared/Ableton/Database"
/usr/sbin/chown -fR 0:0 "/Users/Shared/Ableton/Factory Packs"

# Create the log files directory
if [ -n "${LOGFILESDIR}" ]; then
    /bin/mkdir -p "${LOGFILESDIR}" 2>/dev/null
fi


# 3.2 Ableton Live Packs
# admin group write access so the move operation works.
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


