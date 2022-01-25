#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it




# This script requires one parameter value for display sleep timer (value in minutes, or 0 to disable) on AC power.

# The -a, -b, -c, -u flags determine whether the settings apply to battery ( -b ), charger (wall power) ( -c ), UPS ( -u ) or all ( -a ).

# Use a minutes argument of 0 to set the idle time to never.
# 
# Postponed script execution in DeployStudio. Commands must run as root.

# Change History:
# 2012/10/23:	Creation.
# 2016/07/01:	Updated comments and full path to pmset.
#


SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

echo "***Begin $SCRIPTNAME script***"
/bin/date

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

# set -x # For debugging, show commands.

# Jamf JSS Parameters 1 through 3 are predefined as mount point, computer name, and username

pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3

shift 3
# Shift off the $1 $2 $3 parameters passed by the JSS so that parameter 4 is now $1


displaySleep=$1

# system sleep timer (value in minutes, or 0 to disable)
echo "System sleep timer = Never"
/usr/bin/pmset -c sleep 0

# wake on ethernet magic packet (value = 0/1)
echo "Wake on ethernet magic packet"
/usr/bin/pmset -a womp 1

# automatic restart on power loss (value = 0/1)
echo "Automatic restart on power loss"
/usr/bin/pmset -c autorestart 1

# display sleep timer; replaces 'dim' argument in 10.4 (value in minutes, or 0 to disable)
if [ "$displaySleep" ] && [ "$displaySleep" != "" ]
then
	echo "Display sleep timer = $displaySleep  minutes"
	/usr/bin/pmset -c displaysleep $displaySleep
fi

# Prints the power management settings in use by the system.
/usr/bin/pmset -g


echo "***End $SCRIPTNAME script***"
/bin/date

exit 0
