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
# 2021/03/17:	Creation.
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


# Example:
# /bin/ls -FlOah "${SCRIPTPATH}"
apiURL='https://csumb.jamfcloud.com:443/JSSResource/computers/serialnumber/'
apiUser="$1"
apiPass="$2"

serial=$(system_profiler SPHardwareDataType | grep "Serial Number" | awk '{print $4}')

# test output
/usr/bin/curl -s -u ${apiUser}:${apiPass} "${apiURL}${serial}" | /usr/bin/xpath '/computer/extension_attributes/extension_attribute[id = "71"]/value/text()'

sleep 1 

ComputerName=$(/usr/bin/curl -s -u ${apiUser}:${apiPass} "${apiURL}${serial}" | /usr/bin/xpath '/computer/extension_attributes/extension_attribute[id = "71"]/value/text()' 2>/dev/null)

echo "ComputerName:${ComputerName}"

# if no value, try again
if [ -z "${ComputerName}" ]; then
	echo "No computer name value; Try again..."
	sleep 2
	ComputerName=$(/usr/bin/curl -s -u ${apiUser}:${apiPass} "${apiURL}${serial}" | /usr/bin/xpath '/computer/extension_attributes/extension_attribute[id = "71"]/value/text()' 2>/dev/null)
	echo "ComputerName:${ComputerName}"
fi

if [ ! -z "${ComputerName}" ]; then
	/usr/local/bin/jamf setComputerName -name "${ComputerName}"
else
	/usr/local/bin/jamf setComputerName -useSerialNumber
fi

/usr/local/bin/jamf recon



# https://www.jamf.com/jamf-nation/discussions/26699/computer-rename-based-on-jamfpro-object-attributes#responseChild158613

exit 0
