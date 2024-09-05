#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Uninstall script for Blackmagic DaVinci Resolve 18.x (and Studio).
# Using code in script from Resolve uninstall application.
# /Volumes/Blackmagic DaVinci Resolve/Uninstall Resolve.app/Contents/Resources/uninstall.sh
# 
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

# Test whether Resolve is already installed. Exit if not found.

 if [ ! -e "$mountPoint/Applications/DaVinci Resolve/" ] 
 then
 	echo "/Applications/DaVinci Resolve not found on system, so exiting script..."
 	exit 0
 fi
 

##### vvvvv Borrowed code starts here vvvvv #####

# unconfigure panel
"/Library/Application Support/Blackmagic Design/DaVinci Resolve/configure-panel.sh" none

# unconfigure dp
"/Library/Application Support/Blackmagic Design/DaVinci Resolve/configure-dp.sh" off

# DO NOT blow away application support and prefs
# /bin/rm -rf "/Library/Application Support/Blackmagic Design/DaVinci Resolve/"
# /bin/rm -rf "/Library/Preferences/Blackmagic Design/DaVinci Resolve/"

# Proxy Generator
if [ -e "/Applications/DaVinci Resolve/DaVinci Resolve.app/Contents/Applications/Blackmagic Proxy Generator" ]
then
    /bin/rm -rf "/Applications/Blackmagic Proxy Generator.app"
else
    if [ -e "/Applications/Blackmagic Proxy Generator Lite.app/Contents/Info.plist" ]
    then
        # Check to make sure the app bundle is NOT a standalone build
        \grep ">com.blackmagic-design.BlackmagicProxyGeneratorLite<" "/Applications/Blackmagic Proxy Generator Lite.app/Contents/Info.plist" > /dev/null
        if [ $? -eq 0 ]
        then
            /bin/rm -rf "/Applications/Blackmagic Proxy Generator Lite.app"
        fi
    fi
fi

# Application
/bin/rm -rf "/Applications/DaVinci Resolve/"

# Panels
/bin/rm -rf "/Library/Frameworks/DaVinciPanelAPI.framework"
/bin/rm -rf "/Library/Application Support/Blackmagic Design/DaVinci Resolve Panels/AdminUtility"
/bin/rmdir "/Library/Application Support/Blackmagic Design/DaVinci Resolve Panels"

# Fairlight Panels
/bin/rm -rf "/Library/Frameworks/FairlightPanelAPI.framework"

# Resolve Plugin
/bin/rm -rf "/Library/OFX/Plugins/DaVinci Resolve Renderer.ofx.bundle"

##### ^^^^^ Borrowed code ends here ^^^^^ #####


exit 0
