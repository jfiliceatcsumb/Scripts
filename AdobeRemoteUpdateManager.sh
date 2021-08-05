#!/bin/bash

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script requires Adobe RemoteUpdateManager to be installed.
# 
# Use as script in Jamf JSS.


# Change History:
# 2021/02/19:	Creation.
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


echo "***Begin $SCRIPTNAME script***"
/bin/date

# RemoteUpdateManager version is : 2.4.0.3
# 
# Commandline Usage :
# 
#       RemoteUpdateManager [--proxyUserName=<username> [--proxyPassword=<password>]] [--channelIds=<',' separated channelIds>] [--productVersions=<',' separated productVersions>] [--action=<case-insensitive action verb from {list, download, install}, default is 'install'>] [{-h, -help, --help}]
# 
# RemoteUpdateManager must be launched with elevated privileges.


# Check for /usr/local/bin/RemoteUpdateManager
if [[ -e /usr/local/bin/RemoteUpdateManager ]]
then
	# Check for parameters passed to the script
	if [[ "$1" == "" ]]
	then
		/usr/local/bin/RemoteUpdateManager
	else
		/usr/local/bin/RemoteUpdateManager --productVersions=$1
	fi
else
	echo "Error: Adobe RemoteUpdateManager not installed."
	exit 1
fi

echo "***End $SCRIPTNAME script***"
/bin/date

exit 0
