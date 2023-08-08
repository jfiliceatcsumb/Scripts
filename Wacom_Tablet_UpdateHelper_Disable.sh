#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it


# Script disables Wacom UpdateHelper
# 
# Use as script in Jamf JSS.


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

# <key>Analytics_On</key>
# <string>NO</string>
# <key>PEN_SECOND_RUN</key>
# <string>YES</string>
# <key>TOUCH_SECOND_RUN</key>
# <string>YES</string>
# <key>LastShown</key>
# <string>6.3.46-1</string>

set -x

/bin/launchctl disable system/com.wacom.UpdateHelper
/bin/launchctl unload -wF /Library/LaunchDaemons/com.wacom.UpdateHelper.plist
/usr/bin/defaults write /Library/LaunchDaemons/com.wacom.UpdateHelper.plist 'RunAtLoad' -bool false
/bin/chmod -f 644 /Library/LaunchDaemons/com.wacom.UpdateHelper.plist 
/usr/sbin/chown 0:0 /Library/LaunchDaemons/com.wacom.UpdateHelper.plist 

