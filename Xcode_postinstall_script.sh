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



# Change History:
# 2015/08/26:	Creation.
# 2016/08/03:	Updated for Xcode 7.2.1
# 2016/08/21:	Updated with script code from https://github.com/munki/munki/wiki/Xcode#xcode-7
# 2019/07/26:	Combining installer these scripts: postinstall, Xcode-7.sh, edu.csumb.it.Xcode.DeveloperToolsGroup.sh, edu.csumb.it.Xcode.AccessibilityInspector.sh
# 2019/08/13:	/usr/bin/xcodebuild path
# 2021/08/09:	Redirect stderr to stdout for xcode-select --install. It was causing Jamf job flagging as failure.

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

# If you have multiple versions of Xcode installed, specify which one you want to be current.

if [[ /usr/bin/xcode-select ]]; then
    /usr/bin/xcode-select --switch /Applications/Xcode.app
fi


# Just in case the Accept EULA xcodebuild command below fails to accept the EULA, set the license acceptance info 
# in /Library/Preferences/com.apple.dt.Xcode.plist. For more details on this, see Tim Sutton's post: 
# http://macops.ca/deploying-xcode-the-trick-with-accepting-license-agreements/

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

echo "Run Xcode first launch"
echo "Accept EULA so there is no prompt"
# https://github.com/munki/munki/wiki/Xcode#xcode-7

if [[ -e "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" ]]; then
	echo "Check if any First Launch tasks need to be performed"
	"/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" -checkFirstLaunchStatus

	"/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" -runFirstLaunch
	sleep 1
	"/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" -license accept
	sleep 1
fi
# -allowProvisioningUpdates
#     Allow xcodebuild to communicate with the Apple Developer website. For automatically signed targets, xcodebuild will create and update profiles, app IDs, and certificates. 
#     For manually signed targets, xcodebuild will download missing or updated provisioning profiles. 
#     Requires a developer account to have been added in Xcode's Accounts preference pane.

#     -allowProvisioningDeviceRegistration
#     Allow xcodebuild to register your destination device on the developer portal if necessary. 
#     This flag only takes effect if -allowProvisioningUpdates is also passed.


if [[ -e /usr/bin/xcodebuild ]]; then
  /usr/bin/xcodebuild -runFirstLaunch
  sleep 1
  /usr/bin/xcodebuild -license accept
  sleep 1
fi


# https://stackoverflow.com/questions/15371925/how-to-check-if-command-line-tools-is-installed
/usr/bin/xcode-select -p 2>&1
/usr/bin/xcode-select -p 1>/dev/null;echo $?

# Install Command Line Tools.

if [[ /usr/bin/xcode-select ]]; then
    /usr/bin/xcode-select --install 2>&1
fi


# install embedded packages
# https://github.com/munki/munki/wiki/Xcode
for PKG in /Applications/Xcode.app/Contents/Resources/Packages/*.pkg; do
    /usr/sbin/installer -pkg "$PKG" -target /
done

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
/usr/sbin/dseditgroup -o edit -a everyone -t group _developer


# Allow any member of _developer to install Apple provided software.

/usr/bin/security authorizationdb write system.install.apple-software authenticate-developer

/usr/bin/security authorizationdb write com.apple.dt.instruments.process.analysis authenticate-developer
/usr/bin/security authorizationdb write com.apple.dt.instruments.process.kill authenticate-developer



# Bypass Gatekeeper verification for Xcode, which can take awhile.

if [[ -e "/Applications/Xcode.app" ]]; then xattr -dr com.apple.quarantine /Applications/Xcode.app
fi


# https://github.com/munki/munki/wiki/Xcode#xcode-7
# disable version check for MobileDeviceDevelopment
/usr/bin/defaults write /Library/Preferences/com.apple.dt.Xcode DVTSkipMobileDeviceFrameworkVersionChecking -bool true


defaults read "/Library/Preferences/com.apple.dt.Xcode.plist"
echo "Check if any First Launch tasks need to be performed"
"/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" -checkFirstLaunchStatus



exit 0