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


ServerUrl="${1}"
FileID="${2}"
OrganizationID="${3}"

readonly configFile="/Library/Application Support/JAMF/Waiting Room/com.faronics.cloudagent.plist"

# if file exists, Removes all default information
if [[ -e "${configFile}" ]];then
	/usr/bin/defaults delete "${configFile}"
fi

/usr/bin/defaults write "${configFile}" ServerUrl "$ServerUrl"
/usr/bin/defaults write "${configFile}" FileID "$FileID"
/usr/bin/defaults write "${configFile}" OrganizationID "$OrganizationID"
/usr/bin/defaults read "${configFile}"

exit 0

