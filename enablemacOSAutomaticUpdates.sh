#!/bin/bash

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it




# Run it with 6 arguments. 
# 
# Use as script in Jamf JSS.
# Credit: https://macadminsdoc.readthedocs.io/en/master/Profiles-and-Settings/OS-X-Updates.html

# Change History:
# 2019/02/18:	Creation.
# 2020/03/04:	Added AutomaticallyInstallMacOSUpdates (Mojave)
# 				Added restrict-software-update-require-admin-to-install
# 				Added restrict-store-require-admin-to-install
#

SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

# Jamf JSS Parameters 1 through 3 are predefined as mount point, computer name, and username

pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3

shift 3
# Shift off the $1 $2 $3 parameters passed by the JSS so that parameter 4 is now $1


# set alias for PlistBuddy and several others so I don't have to specify full path.
# Prefix sudo path because I'm using it here for all commands.
# If I want to run a command without the alias, then specify the full path.
alias PlistBuddy="/usr/bin/sudo /usr/libexec/PlistBuddy"
alias chown="/usr/bin/sudo /usr/sbin/chown"
alias chmod="/usr/bin/sudo /bin/chmod"
alias ditto="/usr/bin/sudo /usr/bin/ditto"
alias defaults="/usr/bin/sudo /usr/bin/defaults"
alias rm="/usr/bin/sudo /bin/rm"
alias cp="/usr/bin/sudo /bin/cp"
alias mkdir="/usr/bin/sudo /bin/mkdir"
alias sudo=/usr/bin/sudo


# Setting default values:

# Parameter 4
AutoUpdate=${1:-"TRUE"}

# Parameter 5
AutoUpdateRestartRequired=${2:-"TRUE"}

# Parameter 6
AutomaticCheckEnabled=${3:-"TRUE"}

# Parameter 7
AutomaticDownload=${4:-"TRUE"}

# Parameter 8
CriticalUpdateInstall=${5:-"TRUE"}

# Parameter 9
ConfigDataInstall=${6:-"TRUE"}

# Parameter 10
AutomaticallyInstallAppUpdates=${7:-"TRUE"}

# Parameter 11
RestrictSoftwareUpdateRequireAdminToInstall=${8:-"FALSE"}

AutomaticallyInstallMacOSUpdates=$AutoUpdateRestartRequired
RestrictStoreRequireAdminToInstall=${RestrictSoftwareUpdateRequireAdminToInstall}



defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdate -bool $AutoUpdate
defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdateRestartRequired -bool $AutoUpdateRestartRequired
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticallyInstallMacOSUpdates -bool $AutomaticallyInstallMacOSUpdates
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled -bool $AutomaticCheckEnabled
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticDownload -bool $AutomaticDownload
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist CriticalUpdateInstall -bool $CriticalUpdateInstall
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist ConfigDataInstall -bool $ConfigDataInstall
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticallyInstallAppUpdates -bool $AutomaticallyInstallAppUpdates
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist restrict-software-update-require-admin-to-install -bool ${RestrictSoftwareUpdateRequireAdminToInstall}
defaults write /Library/Preferences/com.apple.appstore.plist restrict-store-require-admin-to-install -bool ${RestrictStoreRequireAdminToInstall}



exit 0


