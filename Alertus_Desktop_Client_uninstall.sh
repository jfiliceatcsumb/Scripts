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


# Change History:
# 2022/09/23:	Creation.
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
# set -x

# Example:
# /bin/ls -FlOah "${SCRIPTDIR}"
#!/bin/sh

# Written after the scripts by Gerrit DeWitt (gdewitt@gsu.edu)

declare -x PATH="/usr/bin:/bin:/usr/sbin:/sbin"

# MARK: VARIABLES
declare -x APP_NAME="Alertus Desktop"
declare -x AQUA_SESSION_USER=$(ls -l /dev/console | cut -d " " -f4)
declare -x AQUA_SESSION_USER_ID=$(id -u "$AQUA_SESSION_USER")
declare -x LOG_PREFIX="/var/log/AlertusDesktoppreinstall.log"
declare -x FAILURE_MSG="$LOG_PREFIX: Could not quit the app; it may not have been open."
declare -x SUDO=''
declare -x INSTALLER_USER=$(stat -f '%Su' $HOME)


if ([ "$AQUA_SESSION_USER" != 0 ]); then
	echo $(date -u) "Script is not running as a root." >> $LOG_PREFIX
	SUDO='sudo'
fi

# Using $mountPoint variable instead of $3 positional parameter for compatibility as JSS script.
if [ "$mountPoint" == "/" ]; then
    echo $(date -u) "Operating on boot volume as user $INSTALLER_USER ($AQUA_SESSION_USER_ID)." >> $LOG_PREFIX
	  if ([ "$AQUA_SESSION_USER" != "" ]); then
		#ITEMS=$(osascript -e 'tell application "System Events" to get the name of every login item' | grep "Alertus Desktop")

		#if [ -z "$ITEMS" ]
			#then
			#echo $(date -u) "Legacy login item not found." >> $LOG_PREFIX
		# else
			# osascript -e 'tell application "System Events" to delete login item "Alertus Desktop"' 
		#fi
		
        echo $(date -u) "Attempting to quit $APP_NAME for $AQUA_SESSION_USER ($AQUA_SESSION_USER_ID)." >> $LOG_PREFIX
        $SUDO touch /var/log/alertus.log
        $SUDO chmod 777 /var/log/alertus.log
        killall Alertus\ Desktop 2>&-
        if launchctl list | grep com.alertus.AlertusDesktopClient ; then
        	echo $(date -u) "Unloading $APP_NAME." >> $LOG_PREFIX
        	$SUDO /bin/launchctl bootout gui/$AQUA_SESSION_USER_ID "/Library/LaunchAgents/com.alertus.AlertusDesktopClient.plist" 2>&-
        	$SUDO rm /Library/LaunchAgents/com.alertus.AlertusDesktopClient.plist
        	$SUDO rm -rf "/Applications/Alertus Desktop.app"
#         	Added this line to complete removal:
        	$SUDO rm -rf "/Library/Application Support/Alertus Technologies"
        	exit 0
        fi
    fi
fi


exit 0

