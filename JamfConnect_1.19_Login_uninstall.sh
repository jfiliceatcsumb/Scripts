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

# Reset the authentication database by executing the following command with the authchanger:
if [[ -e /usr/local/bin/authchanger ]]
then
	/usr/local/bin/authchanger -reset

	# Important: If you do not reset the authentication database before deleting Jamf Connect Login files, users will be unable to log in.

	#Remove the following files installed with Jamf Connect Login by executing the following commands:
	rm /usr/local/bin/authchanger  2>&1
	rm /usr/local/lib/pam/pam_saml.so.2 2>&1
	rm -r /Library/Security/SecurityAgentPlugins/JamfConnectLogin.bundle 2>&1
fi

exit 0
