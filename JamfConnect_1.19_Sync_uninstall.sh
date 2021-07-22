#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Use as script in Jamf JSS.


# Change History:
# 2021/07/22:	Creation.
#

SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

# Jamf JSS Parameters 1 through 3 are predefined as mount point, computer name, and username

pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3

# shift 3
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



# https://docs.jamf.com/jamf-connect/administrator-guide/authchanger.html
# https://docs.jamf.com/jamf-connect/1.19.2/administrator-guide/Uninstalling_Jamf_Connect.html
# https://docs.jamf.com/jamf-connect/1.19.2/administrator-guide/Installation_and_Licensing.html

# Complete the following to uninstall Jamf Connect Sync or Jamf Connect Verify from computers:
# 
# Remove the Jamf Connect Sync or Jamf Connect Verify launch agent from /Library/LaunchAgents.


if [[ -e /Library/LaunchAgents/com.jamf.connect.sync.plist ]]
then
	/bin/launchctl stop com.jamf.connect.sync
	/bin/launchctl unload -wF /Library/LaunchAgents/com.jamf.connect.sync.plist
	/bin/rm -f /Library/LaunchAgents/com.jamf.connect.sync.plist

fi

/usr/bin/killall "Jamf Connect Sync"


# Remove Jamf Connect Sync from /Applicatons .
/bin/rm -fR "/Applications/Jamf Connect Sync.app"


/usr/bin/killall "Jamf Connect Sync"


exit

