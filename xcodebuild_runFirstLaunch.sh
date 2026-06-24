#!/bin/bash

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# http://csumb.edu/it



# This script requires /Applications/Xcode.app .
# Run it with no arguments. 
# 
# For best results, copy it to the Mac and run it as a post-flight task in DeployStudio 
# or postinstall script in a PKG installer.

# Sources:
# https://github.com/munki/munki/wiki/Xcode
# http://macops.ca/deploying-xcode-the-trick-with-accepting-license-agreements/
# https://github.com/munki/munki/wiki/Xcode#xcode-7
# https://workbrew.com/blog/homebrew-xcode-license-management

# https://github.com/rtrouton/rtrouton_scripts/blob/c90890b7711b32fa5fcbc014869891c091375bb5/rtrouton_scripts/xcode_post_install_actions/xcode_post_install_actions.sh



SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

pathToScript=$0
pathToPackage=$1
targetLocation=$2
targetVolume=$3


echo "Run Xcode first launch"

if /usr/bin/xcrun -find xcodebuild >/dev/null 2>&1; then

echo "Check if Xcode is waiting for the license to be accepted"

 if ! /usr/bin/xcodebuild -license check >/dev/null 2>&1; then
   /usr/bin/xcodebuild -license accept
 fi
	echo "Check if any First Launch tasks need to be performed"
 if ! /usr/bin/xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1; then
   /usr/bin/xcodebuild -runFirstLaunch -checkForNewerComponents
 fi
fi

sleep 1

exit 0