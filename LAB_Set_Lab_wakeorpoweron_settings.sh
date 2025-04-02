#!/bin/zsh --no-rcs

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it


# Sets automatic repeating wake/power on schedule for Labs
# 
# Postponed script execution in DeployStudio. Commands must run as root.

# Change History:
# 2015/06/29:	Creation.
#


SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

echo "***Begin $SCRIPTNAME script***"
/bin/date

# Jamf JSS Parameters 1 through 3 are predefined as mount point, computer name, and username

pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3

shift 3
# Shift off the $1 $2 $3 parameters passed by the JSS so that parameter 4 is now $1


# set default values for PMSET
PMSETrepeatTYPE="wakeorpoweron"
PMSETrepeatWEEKDAYS="MTWRFSU"
PMSETrepeatTIME="07:00:00"

echo "Sets automatic repeating wake/power on schedule for Labs."
echo 'Script accepts 3 parameters for "type" "weekdays" "time"'
echo ' or accepts 1 parameter "cancel" (case-insensitive)'
echo ' or without passed parameters, uses hard-coded values from script:'
echo "type=$PMSETrepeatTYPE"
echo "weekdays=$PMSETrepeatWEEKDAYS"
echo "time=$PMSETrepeatTIME"
echo ""

echo "Displaying scheduled startup/wake and shutdown/sleep events..."
/usr/bin/pmset -g sched

# pmset allows you to schedule system sleep, shutdown, wakeup and/or power
# on. "schedule" is for setting up one-time power events, and "repeat" is
# for setting up daily/weekly power on and power off events. Note that you
# may only have one pair of repeating events scheduled - a "power on" event
# and a "power off" event. For sleep cycling applications, pmset can sched-
# ule a "relative" wakeup to occur in seconds from the end of system sleep,
# but this event cannot be cancelled and is inherently imprecise.

# Syntax:
#      pmset repeat cancel
#      pmset repeat type weekdays time
# 
#      type - one of sleep, wake, poweron, shutdown, wakeorpoweron
#      weekdays - a subset of MTWRFSU ("M" and "MTWRF" are valid strings)
#      time - HH:mm:ss


# If exists parameter $1 and is "cancel" case-insensitive 
# http://wiki.bash-hackers.org/syntax/ccmd/conditional_expression
if [[ $1 =~ [Cc][Aa][Nn][Cc][Ee][Ll] ]]
then
	echo 'Canceling all repeating scheduled power events...'
#	/usr/bin/pmset repeat cancel
elif [ $# -ge 3 ]
then
# 	 'at least 3 parameters'
	PMSETrepeatTYPE=${1}
	PMSETrepeatWEEKDAYS=${2}
	PMSETrepeatTIME=${3}
	echo "Setting values to the first 3 passed parameter values..."
	echo "type=$PMSETrepeatTYPE"
	echo "weekdays=$PMSETrepeatWEEKDAYS"
	echo "time=$PMSETrepeatTIME"

#	/usr/bin/pmset repeat ${PMSETrepeatTYPE} ${PMSETrepeatWEEKDAYS} ${PMSETrepeatTIME}


else 	
	echo "Insufficient parameters passed to script."
	echo 'Setting to values to hard-coded values from script...'
	echo "type=$PMSETrepeatTYPE"
	echo "weekdays=$PMSETrepeatWEEKDAYS"
	echo "time=$PMSETrepeatTIME"

#	/usr/bin/pmset repeat ${PMSETrepeatTYPE} ${PMSETrepeatWEEKDAYS} ${PMSETrepeatTIME}


fi


# /usr/bin/pmset repeat wakeorpoweron MTWRFSU 07:00:00
# /usr/bin/pmset 
# /usr/bin/pmset 

echo "Displaying scheduled startup/wake and shutdown/sleep events..."
/usr/bin/pmset -g sched


echo "***End $SCRIPTNAME script***"
/bin/date

exit 0
