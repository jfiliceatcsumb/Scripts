#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script requires .
# Run it with no arguments. 
# 
# Use as script in Jamf JSS.


# Change History:
# 2023/08/25:	Creation.
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

# Example:
# /bin/ls -FlOah "${SCRIPTDIR}"


/usr/bin/defaults write "/System/Library/User Template/Non_localized/Library/Preferences/com.apple.HIToolbox.plist" AppleEnabledInputSources -array-add \
'<dict>
<key>InputSourceKind</key>
<string>Keyboard Layout</string>
<key>KeyboardLayout ID</key>
<integer>87</integer>
<key>KeyboardLayout Name</key>
<string>Spanish - ISO</string>
</dict>'

/usr/bin/plutil -lint  "/System/Library/User Template/Non_localized/Library/Preferences/com.apple.HIToolbox.plist"

/usr/bin/plutil -p  "/System/Library/User Template/Non_localized/Library/Preferences/com.apple.HIToolbox.plist"
 
/usr/sbin/chown 0:0 "/System/Library/User Template/Non_localized/Library/Preferences/com.apple.HIToolbox.plist"

/usr/sbin/chmod 644 "/System/Library/User Template/Non_localized/Library/Preferences/com.apple.HIToolbox.plist"


exit 0

