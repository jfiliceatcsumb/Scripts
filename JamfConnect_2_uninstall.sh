#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script requires .
# Run it with no arguments. 
# 
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


# Example:
# /bin/ls -FlOah "${SCRIPTPATH}"


# https://docs.jamf.com/jamf-connect/administrator-guide/authchanger.html
# https://docs.jamf.com/jamf-connect/2.4.1/documentation/Uninstalling_Jamf_Connect.html

# Uninstalling the Login Window

# Reset the authentication database by executing the following command with the authchanger:
/usr/local/bin/authchanger -reset

# Important: If you do not reset the authentication database before deleting Jamf Connect Login files, users will be unable to log in.

#Remove the following files installed with Jamf Connect Login by executing the following commands:
rm /usr/local/bin/authchanger
rm /usr/local/lib/pam/pam_saml.so.2
rm -r /Library/Security/SecurityAgentPlugins/JamfConnectLogin.bundle

# Uninstalling the Menu Bar App

# Remove the Jamf Connect app from /Applicatons 
rm -fR "/Applications/Jamf Connect.app"

# Remove the Jamf Connect launch agent from /Library/LaunchAgents
if [[ -f "/Library/LaunchAgents/com.jamf.connect.plist" ]]
then
	/bin/launchctl unload -wF "/Library/LaunchAgents/com.jamf.connect.plist"
	rm -f "/Library/LaunchAgents/com.jamf.connect.plist"
fi

exit
