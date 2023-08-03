#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it


# Script to work around an issue in which the Wacom Desktop Center.app launches when a user logs in. 
# 		This happens by default unless turned off in the app's settings. 
# 		This script sets the pref file in the User Template and applies to the currently logged in user. 
# 		The currently logged in user may often be the account being used to provision the Mac. 
# 
# This script requires Wacom Desktop Center.app (Wacom Tablet Driver) to be installed previously. 
# 		If solution requires the Wacom Desktop Center.app version to make this work.
# 		If the script cannot read the version, then the script logic will bail out.
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

# set -x

WacomPersistentPlist="/Library/Containers/com.wacom.DataStoreMgr/Data/Library/Preferences/.wacom/persistent.plist"
WacomTabletPrefs="/Library/Group Containers/EG27766DY7.com.wacom.WacomTabletDriver/Library/Preferences/com.wacom.wacomtablet.prefs"
WacomDesktopCenterVersion=""

# Wacom changed the name of the app from Wacom Desktop Center.app to Wacom Center.app, so I need to check for both.
if [[ -e "/Applications/Wacom Tablet.localized/Wacom Desktop Center.app/Contents/Info.plist" ]]
then
	WacomDesktopCenterVersion=$(/usr/bin/defaults read "/Applications/Wacom Tablet.localized/Wacom Desktop Center.app/Contents/Info.plist" CFBundleShortVersionString)
elif [[ -e "/Applications/Wacom Tablet.localized/Wacom Center.app/Contents/Info.plist" ]]
then
	WacomDesktopCenterVersion=$(/usr/bin/defaults read "/Applications/Wacom Tablet.localized/Wacom Center.app/Contents/Info.plist" CFBundleShortVersionString)
fi

echo "WacomDesktopCenterVersion $WacomDesktopCenterVersion"

# 
#

# ##### USER TEMPLATE #####
/bin/mkdir -p -m 755 "$(/usr/bin/dirname '/Library/User Template/Non_localized'${WacomPersistentPlist})" 
/usr/bin/defaults write "/Library/User Template/Non_localized${WacomPersistentPlist}" 'Analytics_On' -string "NO"
/usr/bin/defaults write "/Library/User Template/Non_localized${WacomPersistentPlist}" 'PEN_SECOND_RUN' -string "YES"
/usr/bin/defaults write "/Library/User Template/Non_localized${WacomPersistentPlist}" 'TOUCH_SECOND_RUN' -string "YES"
if [[ "$WacomDesktopCenterVersion" != "" ]]; then
	/usr/bin/defaults write "/Library/User Template/Non_localized${WacomPersistentPlist}" 'LastShown' -string "$WacomDesktopCenterVersion"
fi

/bin/chmod 644 "/Library/User Template/Non_localized${WacomPersistentPlist}"
/usr/sbin/chown 0:0 "/Library/User Template/Non_localized${WacomPersistentPlist}"
echo "/Library/User Template/Non_localized${WacomPersistentPlist}..."
/usr/bin/defaults read "/Library/User Template/Non_localized${WacomPersistentPlist}" 

# Turn off Wacom Center Autostart
/usr/bin/sed -i '' -e '$d' -e '/WCAutoStart/d' "/Library/User Template/Non_localized/${WacomTabletPrefs}"
echo '<WCAutoStart type="bool">false</WCAutoStart>' >> "/Library/User Template/Non_localized/${WacomTabletPrefs}"
echo '</root>' >> "/Library/User Template/Non_localized/${WacomTabletPrefs}"


# ##### CURRENT LOGGED IN USER #####
if [[ "$userName" != "" ]]
then
	if [[  -d "/Users/$userName" ]]
	then
		/bin/mkdir -p -m 755 "$(/usr/bin/dirname /Users/$userName/${WacomPersistentPlist})" 
		/usr/bin/defaults write "/Users/$userName/${WacomPersistentPlist}" 'Analytics_On' -string "NO"
		/usr/bin/defaults write "/Users/$userName/${WacomPersistentPlist}" 'PEN_SECOND_RUN' -string "YES"
		/usr/bin/defaults write "/Users/$userName/${WacomPersistentPlist}" 'TOUCH_SECOND_RUN' -string "YES"
		if [[ "$WacomDesktopCenterVersion" != "" ]]; then
				/usr/bin/defaults write "/Users/$userName/${WacomPersistentPlist}" 'LastShown' -string "$WacomDesktopCenterVersion"
		fi
		/usr/sbin/chown $userName "/Users/$userName/${WacomPersistentPlist}"
		echo "/Users/$userName/${WacomPersistentPlist}..."
		/usr/bin/defaults read "/Users/$userName/${WacomPersistentPlist}"
		
		# Turn off Wacom Center Autostart
		/bin/mkdir -p -m 755 "$(/usr/bin/dirname /Users/$userName/${WacomTabletPrefs})"
		/usr/bin/sed -i '' -e '$d' -e '/WCAutoStart/d' "/Users/$userName/${WacomTabletPrefs}"
		echo '<WCAutoStart type="bool">false</WCAutoStart>' >> "/Users/$userName/${WacomTabletPrefs}"
		echo '</root>' >> "/Users/$userName/${WacomTabletPrefs}"

	fi
fi


