#!/bin/bash --noprofile --norc
# 
# https://raw.githubusercontent.com/amsysuk/public_scripts/master/configureLoginWindowAccess.sh
# https://dazwallace.wordpress.com/2017/12/14/limit-access-to-the-login-window-using-a-script/
# 

# Ff using an AD group, the device must be bound to AD before running this script.
# Run it with two arguments. 
# Parameter 4 
# Name of group that is allowed to log into the Mac (AD, OD or Local)
# 
# Parameter 5
# Should local users also have access? 
# Acceptable Answers: "admin" "all" "no" (all lower case)
# 
# Use as script in Jamf JSS.

SCRIPTNAME=$(/usr/bin/basename "$0")
SCRIPTDIR=$(/usr/bin/dirname "$0")

# Jamf JSS Parameters 1 through 3 are predefined as mount point, computer name, and username

pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3

echo "pathToScript=$pathToScript"
echo "mountPoint=$mountPoint"
echo "computerName=$computerName"
echo "userName=$userName"

#########################################################################################
# Author:   Darren Wallace - Amsys
# Name:     configureLoginWindowAccess.sh
#
# Purpose:  This script will configure the login window to only allow users who 
#			are a member of the user group specified in line 33 to login. 
#			Please Note: This group needs to be accessable by the end device
#			E.g. if using an AD group, the device must be bound to AD before 
#			pushing this script out.
#			Optionally, it can also be used to also allow local admin users or 
#			all local users, by editing line 36.
#			"admin" will only add the specified group and the local 'admin' 
#			group. "all" will only add the specified group and all local users.
#
# Credit:   Thanks to Greg Neagle's post on JamfNation for the details on what was requried
#           https://www.jamf.com/jamf-nation/discussions/14476/automate-mobile-users-allowed-to-log-in-to-a-system-as-the-first-user-to-login-only#responseChild88282
#
# Usage:    CLI | Jamf Pro
#
# Version 2017.12.12 - DW - Initial Creation
#
#########################################################################################

##################################### Set variables #####################################

# Name of the script
scriptName="${SCRIPTNAME}"
# Location of the LogFile to save output to
logFile="/Library/Logs/${scriptName}.log"
# Name of group that is allowed to log into the Mac (AD, OD or Local)
allowGroup="${4}"
# Should local users also have access? 
# Acceptable Answers: "admin" "all" "no" (all lower case)
extraUsers="${5}"

################################## Declare functions ####################################

# Function to write input to the terminal and a logfile
writeLog ()
{
	/bin/echo "$(date) - ${1}"
	/bin/echo "$(date) - ${1}" >> "${logFile}"
}

################################## Parameter Input Checks ################################

# Check if allowGroup (Parameter 4) is provided
if [[ -z "${allowGroup}" ]]; then
    writeLog "ERROR: No group specified in parameter 4 (allowGroup)."
    writeLog "Usage: Run this script with parameter 4 set as the name of the group allowed to log in."
    writeLog "Script exiting due to missing parameter."
    exit 1
fi

# Check if extraUsers (Parameter 5) is provided
if [[ -z "${extraUsers}" ]]; then
    writeLog "ERROR: No local user access option specified in parameter 5 (extraUsers)."
    writeLog "Usage: Run this script with parameter 5 set as one of: admin, all, no"
    writeLog "Script exiting due to missing parameter."
    exit 1
fi

# Validate extraUsers input
if [[ "${extraUsers}" != "admin" && "${extraUsers}" != "all" && "${extraUsers}" != "no" ]]; then
    writeLog "ERROR: Parameter 5 (extraUsers) must be one of: admin, all, no"
    writeLog "You provided: '${extraUsers}'"
    writeLog "Script exiting due to invalid parameter."
    exit 1
fi

##################################### Run Script #######################################

writeLog "Starting script: ${scriptName}"

# Create the two required groups to limit AD access at the login window
writeLog "Checking for existence of com.apple.loginwindow.netaccounts group"
CHECK_netaccounts=$(/usr/sbin/dseditgroup -q -o read com.apple.loginwindow.netaccounts 2>&1 | grep --only-matching "Group not found" )
if [[ -n "${CHECK_netaccounts}" ]]
then
	writeLog "Creating the com.apple.loginwindow.netaccounts group"
	/usr/sbin/dseditgroup -v -o create com.apple.loginwindow.netaccounts
fi

writeLog "Checking for existence of com.apple.access_loginwindow group"
CHECK_access_loginwindow=$(/usr/sbin/dseditgroup -q -o read com.apple.access_loginwindow 2>&1 | grep --only-matching "Group not found" )
if [[ -n "${CHECK_access_loginwindow}" ]]
then
	writeLog "Creating the com.apple.access_loginwindow group"
	/usr/sbin/dseditgroup -v -o create com.apple.access_loginwindow
fi


# Add the primary group ($allowGroup) to the 'allow' login list
writeLog "Adding the primary group to the login allow list"
	/usr/sbin/dseditgroup -o edit -n /Local/Default -a "${allowGroup}" -t group com.apple.loginwindow.netaccounts

# Adding the netaccounts group to the access group
writeLog "Adding the netaccounts group to the access group"
	/usr/sbin/dseditgroup -o edit -n /Local/Default -a com.apple.loginwindow.netaccounts -t group com.apple.access_loginwindow
	
# Check if there are additional groups to be added
writeLog "Check if there are additional groups to be added"
if [[ "${extraUsers}" == "admin" ]]; then
	writeLog "Adding the admin group to the access list"
	/usr/sbin/dseditgroup -o edit -n /Local/Default -a admin -t group com.apple.access_loginwindow
elif [[ "${extraUsers}" == "all" ]]; then
	writeLog "Adding all local users group (localaccounts) to the access list"
	/usr/sbin/dseditgroup -o edit -n /Local/Default -a localaccounts -t group com.apple.access_loginwindow
else
	writeLog "No additional users to add"
fi

writeLog "Script Complete"

exit

##################################### End Script #######################################