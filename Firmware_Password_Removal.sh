#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script requires /Library/Application Support/JAMF/bin/setregproptool.
# 
# Use as script in Jamf JSS.


# Change History:
# 2018/05/07:	Creation.
# 2020/04/21:	Added better status echoes and password status that makes more sense.
# 2020/08/05:	changed script to accept just 1 password. Script can be run multiple times to attempt several different firmware passwords
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


# https://www.jamf.com/jamf-nation/articles/58/setting-efi-passwords-on-mac-computers-models-late-2010-or-later
# To remove a firmware password:
# Follow the instructions in the “Administering Open Firmware/EFI Passwords” section of the Casper Suite Administrator’s Guide. For the hardware listed above, you must add a script with the following command to Casper Remote or the policy in the JSS:

# Check whether password is enabled. 
# return status of 0 if set, 1 otherwise.
echo "Pre-check whether firmware password is set..."
setregproptoolresult=""
setregproptoolresult=$("/Library/Application Support/JAMF/bin/setregproptool" -c; echo $?)
if [ "$setregproptoolresult" = "0" ]; then
    echo "Firmware password is set."
else
    echo "Firmware password is not set."
    exit
fi


echo "Attempting to disable firmware, trying several known passwords..."

# Test that there is at least one parameter for the old password.
if [ $# -ge 1 ]
then
	while [ $# != 0 ]
	do
		if [ "${1}" != "" ]; then
# 		firmwarePasswordCommand="/Library/Application Support/JAMF/bin/setregproptool -d -o ${1}"
# spawn 	{*}$firmwarePasswordCommand
			/usr/bin/expect <<EOL
spawn "/Library/Application Support/JAMF/bin/setregproptool" -d -o "${1}"
expect "Enter current password" {
close
send_error "Error: Incorrect old firmware password"
}
EOL
			echo $?
			sleep 1
		
		fi
# 		shift off one argument, before loop back.
		shift

    # Check whether password is enabled. 
    # return status of 0 if set, 1 otherwise.
# 	echo "Check again whether firmware password is set..."
# 	setregproptoolresult=""
# 	setregproptoolresult=$("/Library/Application Support/JAMF/bin/setregproptool" -c; echo $?)
# 	if [ "$setregproptoolresult" = "0" ]; then
# 		echo "Firmware password is set."
# 	else
#     	echo "Firmware password is not set."
# 		exit
# 	fi
	done
else 
	exit 1
fi


exit

