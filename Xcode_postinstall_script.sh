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
# https://github.com/rtrouton/rtrouton_scripts/blob/c90890b7711b32fa5fcbc014869891c091375bb5/rtrouton_scripts/xcode_post_install_actions/xcode_post_install_actions.sh




# Change History:
# 2015/08/26:	Creation.
# 2016/08/03:	Updated for Xcode 7.2.1
# 2016/08/21:	Updated with script code from https://github.com/munki/munki/wiki/Xcode#xcode-7
# 2019/07/26:	Combining installer these scripts: postinstall, Xcode-7.sh, edu.csumb.it.Xcode.DeveloperToolsGroup.sh, edu.csumb.it.Xcode.AccessibilityInspector.sh
# 2019/08/13:	/usr/bin/xcodebuild path
# 2021/08/09:	Redirect stderr to stdout for xcode-select --install. It was causing Jamf job flagging as failure.
# 2023/08/08:	Added more log output echoes and added explicit paths to several commands, for better security.

SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

pathToScript=$0
pathToPackage=$1
targetLocation=$2
targetVolume=$3



# set alias for PlistBuddy and several others so I don't have to specify full path.
# Prefix sudo path because I'm using it here for all commands.
# If I want to run a command without the alias, then specify the full path.
alias PlistBuddy="/usr/libexec/PlistBuddy"
alias chown="/usr/sbin/chown"
alias chmod="/bin/chmod"
alias ditto="/usr/bin/ditto"
alias defaults="/usr/bin/defaults"
alias rm="/bin/rm"
alias cp="bin/cp"
alias mkdir="/bin/mkdir"
alias sudo=/usr/bin/sudo


# enable developer mode
# DevToolsSecurity tool to change the authorization policies, such that a user who is a
# member of either the admin group or the _developer group does not need to enter an additional
# password to use the Apple-code-signed debugger or performance analysis tools.
# https://github.com/munki/munki/wiki/Xcode
echo "Enable developer mode"
/usr/sbin/DevToolsSecurity -enable
/usr/sbin/DevToolsSecurity -status

# make sure all users on this machine are members of the _developer group
# https://github.com/munki/munki/wiki/Xcode
echo "Make sure all users on this machine are members of the _developer group..."
/usr/sbin/dseditgroup -o edit -a everyone -t group _developer


# Allow any member of _developer to install Apple provided software.
echo "Allow any member of _developer to install Apple provided software..."
/usr/bin/security authorizationdb write system.install.apple-software authenticate-developer

/usr/bin/security authorizationdb write com.apple.dt.instruments.process.analysis authenticate-developer
/usr/bin/security authorizationdb write com.apple.dt.instruments.process.kill authenticate-developer





# If you have multiple versions of Xcode installed, specify which one you want to be current.
echo "xcode-select /Applications/Xcode.app..."
if [[ /usr/bin/xcode-select ]]; then
    /usr/bin/xcode-select --switch /Applications/Xcode.app
fi

echo "Accept EULA so there is no prompt"

# #####
# https://github.com/rtrouton/rtrouton_scripts/blob/c90890b7711b32fa5fcbc014869891c091375bb5/rtrouton_scripts/xcode_post_install_actions/xcode_post_install_actions.sh
# 
# 
# Accept EULA so there is no prompt

if [[ -e "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" ]]; then
  "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" -license accept
fi

# Just in case the xcodebuild command above fails to accept the EULA, set the license acceptance info 
# in /Library/Preferences/com.apple.dt.Xcode.plist. For more details on this, see Tim Sutton's post: 
# http://macops.ca/deploying-xcode-the-trick-with-accepting-license-agreements/

echo "In case the xcodebuild command above fails to accept the EULA, set the license acceptance info in /Library/Preferences/com.apple.dt.Xcode.plist..."
if [[ -e "/Applications/Xcode.app/Contents/Resources/LicenseInfo.plist" ]]; then

   xcode_version_number=`/usr/bin/defaults read "/Applications/Xcode.app/Contents/"Info CFBundleShortVersionString`
   xcode_build_number=`/usr/bin/defaults read "/Applications/Xcode.app/Contents/Resources/"LicenseInfo licenseID`
   xcode_license_type=`/usr/bin/defaults read "/Applications/Xcode.app/Contents/Resources/"LicenseInfo licenseType`
   
   if [[ "${xcode_license_type}" == "GM" ]]; then
       /usr/bin/defaults write "/Library/Preferences/"com.apple.dt.Xcode IDEXcodeVersionForAgreedToGMLicense "$xcode_version_number"
       /usr/bin/defaults write "/Library/Preferences/"com.apple.dt.Xcode IDELastGMLicenseAgreedTo "$xcode_build_number"
    else
       /usr/bin/defaults write "/Library/Preferences/"com.apple.dt.Xcode IDEXcodeVersionForAgreedToBetaLicense "$xcode_version_number"
       /usr/bin/defaults write "/Library/Preferences/"com.apple.dt.Xcode IDELastBetaLicenseAgreedTo "$xcode_build_number"
   fi       
   
fi


# Install Mobile Device Package so there is no prompt
# 
# if [[ -e "/Applications/Xcode.app/Contents/Resources/Packages/MobileDevice.pkg" ]]; then
#   /usr/sbin/installer -dumplog -verbose -pkg "/Applications/Xcode.app/Contents/Resources/Packages/MobileDevice.pkg" -target /
# fi
# 
# if [[ -e "/Applications/Xcode.app/Contents/Resources/Packages/MobileDeviceDevelopment.pkg" ]]; then
#   /usr/sbin/installer -dumplog -verbose -pkg "/Applications/Xcode.app/Contents/Resources/Packages/MobileDeviceDevelopment.pkg" -target /
# fi
# 
# # Install Xcode System Resources Package, available in Xcode 8 and later
# 
# if [[ -e "/Applications/Xcode.app/Contents/Resources/Packages/XcodeSystemResources.pkg" ]]; then
#   /usr/sbin/installer -dumplog -verbose -pkg "/Applications/Xcode.app/Contents/Resources/Packages/XcodeSystemResources.pkg" -target /
# fi
# 
# 
# #####


# install embedded packages
# https://github.com/munki/munki/wiki/Xcode
echo "Installing all Xcode resource packages, such as mobile device support..."
for PKG in /Applications/Xcode.app/Contents/Resources/Packages/*.pkg; do
    /usr/sbin/installer -dumplog -verbose -pkg "$PKG" -target /
done



echo "Run Xcode first launch tasks..."
# https://github.com/munki/munki/wiki/Xcode#xcode-7

echo "Check if any First Launch tasks need to be performed..."
"/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" -checkFirstLaunchStatus

"/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" -runFirstLaunch
/usr/bin/xcodebuild -runFirstLaunch
echo "Download and install all device platform simulators: iOS Simulator, watchOS Simulator, tvOS Simulator..."
/usr/bin/xcodebuild -downloadAllPlatforms
/bin/sleep 1

# -allowProvisioningUpdates
#     Allow xcodebuild to communicate with the Apple Developer website. For automatically signed targets, xcodebuild will create and update profiles, app IDs, and certificates. 
#     For manually signed targets, xcodebuild will download missing or updated provisioning profiles. 
#     Requires a developer account to have been added in Xcode's Accounts preference pane.

#     -allowProvisioningDeviceRegistration
#     Allow xcodebuild to register your destination device on the developer portal if necessary. 
#     This flag only takes effect if -allowProvisioningUpdates is also passed.




# https://stackoverflow.com/questions/15371925/how-to-check-if-command-line-tools-is-installed
echo "Check if command line tools are installed..."
/usr/bin/xcode-select -p 2>&1
/usr/bin/xcode-select -p 1>/dev/null;echo $?

# #####
echo "(Re)Install Command Line Tools..."
# 
# create the placeholder file that's checked by CLI updates' .dist code
# in Apple's SUS catalog
/usr/bin/touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
# find the CLI Tools update
PROD=$(/usr/sbin/softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')
# 	Strip "Label: "
PROD=$(echo "$PROD" | sed -e 's/Label: //')

# install it
/usr/sbin/softwareupdate -i "$PROD" --verbose
/bin/rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
# 
# 
# #####


# https://community.jamf.com/t5/jamf-pro/deploying-xcode-8-via-self-service-a-how-to/m-p/174953/highlight/true#M163832

echo "Bypass Gatekeeper verification for Xcode, which can take awhile..."

if [[ -e "/Applications/Xcode.app" ]]; then 
	/usr/bin/xattr -dr com.apple.quarantine /Applications/Xcode.app
fi


# https://github.com/munki/munki/wiki/Xcode#xcode-7
echo "Disable version check for MobileDeviceDevelopment..."
/usr/bin/defaults write /Library/Preferences/com.apple.dt.Xcode DVTSkipMobileDeviceFrameworkVersionChecking -bool true

echo "read /Library/Preferences/com.apple.dt.Xcode.plist"
/usr/bin/defaults read "/Library/Preferences/com.apple.dt.Xcode.plist"
# echo "Check if any First Launch tasks need to be performed"
# "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" -checkFirstLaunchStatus


exit 0