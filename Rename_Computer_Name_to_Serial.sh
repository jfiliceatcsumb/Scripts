#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# http://csumb.edu/it


# This script will rename the computer name to serial number.



SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`


/usr/local/bin/jamf setComputerName -useSerialNumber

/usr/local/bin/jamf recon


exit 0
