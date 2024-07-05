#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it


# Script to uninstall Alertus Desktop.
# Based on preinstall script in Alertus Desktop Client 2.12.02.1796 installer pkg
# Run it with no arguments. 
# 
# Use as script in Jamf JSS.


SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTDIR=`/usr/bin/dirname "$0"`

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

# ##### Debugging flags #####
# debug bash script by enabling verbose “-v” option
# set -v
# debug bash script using noexec (Test for syntaxt errors)
# set -n
# identify the unset variables while debugging bash script
# set -u
# debug bash script using xtrace
set -x

# Example:
# /bin/ls -FlOah "${SCRIPTDIR}"
#!/bin/sh

# Written after the scripts by Gerrit DeWitt (gdewitt@gsu.edu)

declare -x PATH="/usr/bin:/bin:/usr/sbin:/sbin"

# MARK: VARIABLES
declare -x APP_NAME="Alertus Desktop"
declare -x AQUA_SESSION_USER="${userName}"
declare -x AQUA_SESSION_USER_ID=$(id -u "$AQUA_SESSION_USER")

if ([ "$AQUA_SESSION_USER" != "" ])
then
	
	echo $(date -u) "Attempting to quit $APP_NAME for $AQUA_SESSION_USER ($AQUA_SESSION_USER_ID)." 

	/usr/bin/killall Alertus\ Desktop 2>&-

	if launchctl list | grep com.alertus.AlertusDesktopClient 
	then
		echo $(date -u) "Unloading $APP_NAME." 
		/bin/launchctl bootout gui/$AQUA_SESSION_USER_ID "${mountPoint}/Library/LaunchAgents/com.alertus.AlertusDesktopClient.plist" 2>&-
	fi
fi

if [ -e "${mountPoint}/Library/LaunchAgents/com.alertus.AlertusDesktopClient.plist" ]
then
	/bin/rm  "${mountPoint}/Library/LaunchAgents/com.alertus.AlertusDesktopClient.plist"
else
	echo "File path ${mountPoint}/Library/LaunchAgents/com.alertus.AlertusDesktopClient.plist not found"
fi
	if [ -e "${mountPoint}/Applications/Alertus Desktop.app" ]
	then
	echo "Deleting ${mountPoint}/Applications/Alertus Desktop.app..."
	/bin/rm  -rfv "${mountPoint}/Applications/Alertus Desktop.app"
else
	echo "File path ${mountPoint}/Applications/Alertus Desktop.app not found"
fi

#         	Added this line to complete removal:
if [ -e "${mountPoint}/Library/LaunchAgents/com.alertus.AlertusDesktopClient.plist" ]
then
	/bin/rm  "${mountPoint}/Library/LaunchAgents/com.alertus.AlertusDesktopClient.plist"
else
	echo "File path ${mountPoint}/Library/LaunchAgents/com.alertus.AlertusDesktopClient.plist not found"
fi

if [ -e "${mountPoint}/Library/Application Support/Alertus Technologies" ]
then
	echo "Deleting ${mountPoint}/Library/Application Support/Alertus Technologies..."
	/bin/rm  -rfv "${mountPoint}/Library/Application Support/Alertus Technologies"
else
	echo "File path ${mountPoint}/Library/Application Support/Alertus Technologies not found"
fi
# /bin/rm  -rfv "${mountPoint}/Library/Application Support/Alertus Technologies"


exit

