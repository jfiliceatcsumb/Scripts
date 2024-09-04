#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it
# https://github.com/jfiliceatcsumb


# Uninstall the Cisco AnyConnect VPN client for Mac.
# Use as script in Jamf JSS.


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



# debug logging
# set -x 
# echo "userName=$userName"

if [ -e /opt/cisco/anyconnect/bin/vpn_uninstall.sh ]; then
	echo "Cisco Anyconnect uninstall running..."
	set -x 
	/opt/cisco/anyconnect/bin/vpn_uninstall.sh
else
	echo "Cisco Anyconnect uninstall not found."
	exit 0
fi

exit 0

