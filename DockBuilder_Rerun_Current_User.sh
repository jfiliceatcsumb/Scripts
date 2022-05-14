#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# https://github.com/ryangball/DockBuilder#re-create-a-users-dock

# Use as script in Jamf JSS.


# Change History:
# 2022/05/15:	Creation.
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

# set alias for PlistBuddy and several others so I don't have to specify full path.
# Prefix sudo path because I'm using it here for all commands.
# If I want to run a command without the alias, then specify the full path.
alias PlistBuddy="/usr/libexec/PlistBuddy"
alias chown="/usr/sbin/chown"
alias chmod="/bin/chmod"
alias ditto="/usr/bin/ditto"
alias defaults="/usr/bin/defaults"
alias rm="/bin/rm"
alias cp="/bin/cp"
alias mkdir="/bin/mkdir"
alias sudo=/usr/bin/sudo


# Example:
# /bin/ls -FlOah "${SCRIPTDIR}"
# Delete the breadcrumb for the user if it exists
userHome=$(/usr/bin/dscl . read "/Users/$userName" NFSHomeDirectory | awk '{print $NF}')
echo userHome=$userHome
if [[ -e $userHome/Library/Preferences/com.github.ryangball.dockbuilder.breadcrumb.plist ]]; then
	/bin/rm $userHome/Library/Preferences/com.github.ryangball.dockbuilder.breadcrumb.plist
fi
userID=$(id -ur $userName)
echo userID=$userID


# Unload the LaunchAgent
# /bin/launchctl unload /Library/LaunchAgents/com.github.ryangball.dockbuilder.plist
/bin/launchctl bootout gui/$userID/ /Library/LaunchAgents/com.github.ryangball.dockbuilder.plist

# Load the LaunchAgent
# /bin/launchctl load /Library/LaunchAgents/com.github.ryangball.dockbuilder.plist
/bin/launchctl bootstrap gui/$userID/ /Library/LaunchAgents/com.github.ryangball.dockbuilder.plist

# Start the LaunchAgent (if necessary)
# /bin/launchctl start com.github.ryangball.dockbuilder
/bin/launchctl kickstart -k gui/$userID/com.github.ryangball.dockbuilder

exit 0