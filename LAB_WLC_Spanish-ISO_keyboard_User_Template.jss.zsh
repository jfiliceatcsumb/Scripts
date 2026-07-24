#!/bin/zsh --no-rcs

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it


# This script adds Apple Spanish ISO keyboard to the input methods menu.

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

# Example:
# /bin/ls -FlOah "${SCRIPTDIR}"

FILEPATH="/System/Library/User Template/Non_localized/Library/Preferences/com.apple.HIToolbox.plist"

/usr/bin/defaults write "${FILEPATH}" AppleEnabledInputSources -array-add \
'<dict>
<key>InputSourceKind</key>
<string>Keyboard Layout</string>
<key>KeyboardLayout ID</key>
<integer>87</integer>
<key>KeyboardLayout Name</key>
<string>Spanish - ISO</string>
</dict>'

/usr/bin/plutil -lint "${FILEPATH}"

/usr/bin/plutil -p "${FILEPATH}"
 
/usr/sbin/chown 0:0 "${FILEPATH}"

/bin/chmod 644 "${FILEPATH}"


exit 0

