#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# http://csumb.edu/it


SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

echo "***Begin $SCRIPTNAME script***"

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


# Desktop Laptop Employee
ImagePlacement='Crop'
ImageFilePath='/Library/Desktop Pictures/Wave.jpg'
NewImageFilePath='/Library/Desktop Pictures/Wave.jpg'
ChangePath='/Library/Desktop Pictures'
NewChangePath='/Library/Desktop Pictures'
UserFolderPaths=''
NoImage_bool='false'
# CSUMB blue
BackgroundColorReal1='0.0'
BackgroundColorReal2='0.11965226382017136'
BackgroundColorReal3='0.29628658294677734'

if [[ -n "$1" ]]; then
	ImageFilePath="$1"
	NewImageFilePath="$1"
fi

# ImagePlacement can be one of the following five options:
# 	'Centered' = preference pane's "Center"
# 	'Crop' = preference pane's "Fill Screen"
# 	'SizeToFit' = preference pane's "Fit To Screen"
# 	'FillScreen' = preference pane's "Stretch To Fill Screen"
# 	'Tiled' = preference pane's "Tile"
# 	'Automatic' may also be an acceptable option. It appears to equal "Fill Screen"
# 
# If you want just the background color, set NoImage-bool to 'true'

osXversion=$(sw_vers -productVersion)
echo "osXversion=$osXversion"
# Just get the second version value after 10.
macOSversionMajor=$(echo $osXversion | awk -F. '{print $1}')
macOSversionMinor=$(echo $osXversion | awk -F. '{print $2}')
echo "macOSversionMajor=$macOSversionMajor"
echo "macOSversionMinor=$macOSversionMinor"

# if 
# macOS 11.x or newer
# or
# macOS 10.15.x or newer

if [ $macOSversionMajor -gt 10 ] || [ $macOSversionMajor -eq 10 -a $macOSversionMinor -ge 15 ]; then
	echo "10.15 and newer"
	USER_TEMPL='/Library/User Template/Non_localized'
else
	echo "older than 10.15"
	USER_TEMPL='/System/Library/User Template/Non_localized'
fi

echo "USER_TEMPL=$USER_TEMPL"

mkdir -pv -m 755 "${USER_TEMPL}/Library/Preferences"


echo "Setting desktop background picture to ${ImageFilePath}..."
defaults write "${USER_TEMPL}/Library/Preferences/com.apple.desktop.plist" Background -dict "default" "<dict> <key>BackgroundColor</key> <array> <real>${BackgroundColorReal1}</real> <real>${BackgroundColorReal2}</real> <real>${BackgroundColorReal3}</real> </array> <key>Change</key> <string>Never</string> <key>ChangePath</key> <string>${ChangePath}</string> <key>ChangeTime</key> <real>1800</real> <key>DSKDesktopPrefPane</key> <dict> <key>UserFolderPaths</key> <array> ${UserFolderPaths} </array> </dict> <key>DrawBackgroundColor</key> <true/> <key>ImageFilePath</key> <string>${ImageFilePath}</string> <key>NewChangePath</key> <string>${NewChangePath}</string> <key>NewImageFilePath</key> <string>${NewImageFilePath}</string> <key>NoImage</key> <${NoImage_bool}/> <key>Placement</key> <string>${ImagePlacement}</string> <key>Random</key> <false/> </dict>"

echo "Checking com.apple.desktop.plist with plutil..."
/usr/bin/plutil "${USER_TEMPL}/Library/Preferences/com.apple.desktop.plist"
echo "Displaying com.apple.desktop.plist in XML..."
/usr/bin/plutil -convert xml1 -o - "${USER_TEMPL}/Library/Preferences/com.apple.desktop.plist"

# Delete the desktoppicture.db to force the plist to be used.
/bin/rm -fv "${USER_TEMPL}/Library/Application Support/Dock/desktoppicture.db"


echo "***End $SCRIPTNAME script***"


exit 0
