#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# http://csumb.edu/it


# This script will rename the computer name to serial number or ComputerName value from Jamf Pro Extension Attributes.




SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

# Jamf JSS Parameters 1 through 3 are predefined as mount point, computer name, and username

pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3

shift 3
# Shift off the $1 $2 $3 parameters passed by the JSS so that parameter 4 is now $1
## Variables ##

plistlocation="/Library/Managed Preferences/edu.csumb.custom.extensionattributes.plist"

if [[ -e "$plistlocation" ]]; then
	ComputerName=$(/usr/bin/defaults read "${plistlocation}" "ComputerName" 2>/dev/null)
else
	ComputerName=""
fi

if [ ! -z "${ComputerName}" ]; then
	/usr/local/bin/jamf setComputerName -name "${ComputerName}"
else
	/usr/local/bin/jamf setComputerName -useSerialNumber
fi

/usr/local/bin/jamf recon


exit 0
