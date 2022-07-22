#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it

# 
# Use as script in Jamf JSS.


# Change History:
# 2022/07/21:	Creation.
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

echo pathToScript=$pathToScript
echo mountPoint=$mountPoint
echo computerName=$computerName
echo userName=$userName


# https://support.apple.com/en-us/HT207568

# You can use a configuration profile to set an alternative plist. In the profile, set the AllowDockFixupOverride key to true in the com.apple.dock domain.
# The Apple provided plist is located at /System/Library/CoreServices/Dock.app/Contents/Resources/com.apple.dockfixup.plist. 
# You can put a modified copy of this file in the /Library/Preferences folder.
# If the configuration profile is active and the com.apple.dockfixup.plist file isn’t located in /Library/Preferences, the original plist and customized plist settings won’t work.

# https://medium.com/@opragel/how-to-customize-stop-dockfixup-on-macos-f349cd3c7b15

# ## Below are the keys included with Apple’s plist:
# “add-app”
# “add-doc”
# move
# “remove-file"
# replace
# "system-apps"
# versions
# 
# ## Brief description of those keys:
# "add-app" Adds app to Dock, either before (left side) or after (right side)
# "add-doc" Add a folder to Dock
# "move" Changes path of matching dock items to new paths
# "replace" Replaces app currently on Dock with another app (iPhotos -> Photos)
# "remove-file" Remove an app/item from Dock


# Copy /System/Library/CoreServices/Dock.app/Contents/Resources/com.apple.dockfixup.plist 
#  to /Library/Preferences/com.apple.dockfixup.plist
#  Then modify /Library/Preferences/com.apple.dockfixup.plist using defaults command
# Remove add-app key

/bin/cp /System/Library/CoreServices/Dock.app/Contents/Resources/com.apple.dockfixup.plist /Library/Preferences/com.apple.dockfixup.plist

/usr/bin/defaults read /Library/Preferences/com.apple.dockfixup.plist 'add-app' 
/usr/bin/defaults delete /Library/Preferences/com.apple.dockfixup.plist 'add-app'

/bin/chmod 644 /Library/Preferences/com.apple.dockfixup.plist
/usr/bin/defaults read /Library/Preferences/com.apple.dockfixup.plist 


/usr/bin/defaults write /Library/Preferences/com.apple.dock.plist AllowDockFixupOverride -bool true
/bin/chmod 644 /Library/Preferences/com.apple.dock.plist
/usr/bin/defaults read /Library/Preferences/com.apple.dock.plist


exit 0

