#!/bin/bash

# Script must run under root

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
if [ "$userName" != "" ]; then
	userIDnum=$(id -u $userName)
else
	userIDnum=""
fi
echo "userIDnum=$userIDnum"

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

# $1 = CustomerUID
# $2 = Client Server Url

# 1. Install app. Install via Jamf Policy
# /usr/sbin/installer -pkg '/Volumes/LabStats/LabStatsInstaller.pkg' -target /

hostFile="/Library/Application Support/LabStatsGo/host.txt"

echo "Remove the host.txt file if it already exists"
rm -rf "$hostFile"

echo "Create host.txt file"
touch "$hostFile"
echo CheckinServer=$2 | tee -a "$hostFile"
echo CustomerUid=$1 | tee -a "$hostFile"
echo AssignmentServer=https://clientserver.labstats.com/ | tee -a "$hostFile"
echo AnonymizeLogins=false | tee -a "$hostFile"

echo "After the host.text file is configured, we can start the service."
set -x
/bin/launchctl unload /Library/LaunchDaemons/labstatsgo.plist 2>  /dev/null
sleep 1
/bin/launchctl load /Library/LaunchDaemons/labstatsgo.plist
sleep 1
if [ "$userName" != "" ]; then
	sudo -u daemon /bin/launchctl unload /Library/LaunchAgents/labstatsgo.plist 2>  /dev/null
	sleep 1
	sudo -u daemon /bin/launchctl load /Library/LaunchAgents/labstatsgo.plist 2>  /dev/null
	sleep 1
	/bin/launchctl bootstrap user/$userIDnum/ /Library/LaunchAgents/labstatsgo.plist 2>  /dev/null
  
fi
set +x
echo "LabStats Installation Complete"
