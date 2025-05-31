#!/bin/zsh --no-rcs

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script requires .
# Run it with 3 arguments:
# 
# ServerUrl
# FileID=
# OrganizationID

# 
# Use as script in Jamf JSS.


# Change History:
# 2025/05/29:	Creation.
#

SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTDIR=`/usr/bin/dirname "$0"`

# Jamf JSS Parameters 1 through 3 are predefined as mount point, computer name, and username

pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3

shift 3
# Shift off the $1 $2 $3 parameters passed by the JSS so that parameter 4 is now $1

echo "pathToScript=$pathToScript"
echo "mountPoint=$mountPoint"
echo "computerName=$computerName"
echo "userName=$userName"


# ##### Debugging flags #####
# debug bash script by enabling verbose “-v” option
# set -v
# debug bash script using noexec (Test for syntaxt errors)
# set -n
# identify the unset variables while debugging bash script
# set -u
# debug bash script using xtrace
# set -x


readonly ServerUrl="${1}"
readonly FileID="${2}"
readonly OrganizationID="${3}"

readonly configFileWaitingRoom="/Library/Application Support/JAMF/Waiting Room/com.faronics.cloudagent.plist"

readonly configFileDownloads="/Library/Application Support/JAMF/Downloads/com.faronics.cloudagent.plist"

# if file exists, Removes all default information
if [[ -e "${configFileWaitingRoom}" ]];then
	/usr/bin/defaults delete "${configFileWaitingRoom}"
fi

# if file exists, Removes all default information
if [[ -e "${configFileDownloads}" ]];then
	/usr/bin/defaults delete "${configFileDownloads}"
fi

/usr/bin/defaults write "${configFileWaitingRoom}" ServerUrl "$ServerUrl"
/usr/bin/defaults write "${configFileWaitingRoom}" FileID "$FileID"
/usr/bin/defaults write "${configFileWaitingRoom}" OrganizationID "$OrganizationID"
/bin/chmod 644 "${configFileWaitingRoom}"
/usr/bin/defaults write "${configFileDownloads}" ServerUrl "$ServerUrl"
/usr/bin/defaults write "${configFileDownloads}" FileID "$FileID"
/usr/bin/defaults write "${configFileDownloads}" OrganizationID "$OrganizationID"
/bin/chmod 644 "${configFileDownloads}"
# Check the property list file for syntax errors
ls -la "${configFileWaitingRoom}"
/usr/bin/plutil "${configFileWaitingRoom}"
ls -la "${configFileDownloads}"
/usr/bin/plutil "${configFileDownloads}"
# debugging: print plist file
# /usr/bin/plutil -p "${configFileWaitingRoom}"
# /usr/bin/plutil -p "${configFileDownloads}"

exit 0

