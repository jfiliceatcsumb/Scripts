#!/bin/zsh --no-rcs

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Sets the default user template to turn off desktop widgets macOS Tahoe..
# Run it with no arguments. 
# 
# Use as script in Jamf JSS.


SCRIPTNAME=$(/usr/bin/basename "$0")
SCRIPTDIR=$(/usr/bin/dirname "$0")

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
FILEPATH="/Library/User Template/Non_localized/Library/Preferences/com.apple.WindowManager.plist"
DIRNAME=$(/usr/bin/dirname "${FILEPATH}")

/bin/mkdir -p -m 0755 "${DIRNAME}"

/usr/bin/defaults write "${FILEPATH}" StageManagerHideWidgets -bool NO
/usr/bin/defaults write "${FILEPATH}" StandardHideWidgets -bool YES

/usr/sbin/chown 0:0 "${FILEPATH}"

echo "read $(/usr/bin/basename ${FILEPATH})"
/usr/bin/defaults read "${FILEPATH}"


exit 


