#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script expects Wacom Tablet Driver to be installed previously.
# 
# Use as script in Jamf JSS.


# Change History:
# 2022/08/16:	Creation.
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

# <key>Analytics_On</key>
# <string>NO</string>
# <key>PEN_SECOND_RUN</key>
# <string>YES</string>
# <key>TOUCH_SECOND_RUN</key>
# <string>YES</string>
# <key>LastShown</key>
# <string>6.3.46-1</string>


WacomPersistentPlist="/Library/Containers/com.wacom.DataStoreMgr/Data/Library/Preferences/.wacom/persistent.plist"
WacomDesktopCenterVersion=""
WacomDesktopCenterVersion=$(/usr/bin/defaults read "/Applications/Wacom Tablet.localized/Wacom Desktop Center.app/Contents/Info.plist" CFBundleShortVersionString)

if [[ "$WacomDesktopCenterVersion" != "" ]]
then
	/bin/mkdir -p -m 755 "$(/usr/bin/dirname '/Library/User Template/Non_localized'${WacomPersistentPlist})" 
	/usr/bin/defaults write "/Library/User Template/Non_localized${WacomPersistentPlist}" 'Analytics_On' -string "NO"
	/usr/bin/defaults write "/Library/User Template/Non_localized${WacomPersistentPlist}" 'PEN_SECOND_RUN' -string "YES"
	/usr/bin/defaults write "/Library/User Template/Non_localized${WacomPersistentPlist}" 'TOUCH_SECOND_RUN' -string "YES"
	/usr/bin/defaults write "/Library/User Template/Non_localized${WacomPersistentPlist}" 'LastShown' -string "$WacomDesktopCenterVersion"
	/bin/chmod 644 "/Library/User Template/Non_localized${WacomPersistentPlist}"
	/usr/sbin/chown 0:0 "/Library/User Template/Non_localized${WacomPersistentPlist}"

	if [[  -d "/Users/$userName" ]]
	then
		/bin/mkdir -p -m 755 "$(/usr/bin/dirname /Users/$userName/${WacomPersistentPlist})" 
		/usr/bin/defaults write "/Users/$userName/${WacomPersistentPlist}" 'Analytics_On' -string "NO"
		/usr/bin/defaults write "/Users/$userName/${WacomPersistentPlist}" 'PEN_SECOND_RUN' -string "YES"
		/usr/bin/defaults write "/Users/$userName/${WacomPersistentPlist}" 'TOUCH_SECOND_RUN' -string "YES"
		/usr/bin/defaults write "/Users/$userName/${WacomPersistentPlist}" 'LastShown' -string "$WacomDesktopCenterVersion"
		/usr/sbin/chown $userName "/Users/$userName/${WacomPersistentPlist}"
	fi
	
fi
