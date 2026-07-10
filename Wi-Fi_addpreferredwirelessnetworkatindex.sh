#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Script to disable Wi-Fi power
# Run it with no arguments. 
# 
# Use as script in Jamf JSS.


# Change History:
# 2022/08/24:	Creation.
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


# ##### Debugging flags #####
# debug bash script by enabling verbose “-v” option
# set -v
# debug bash script using noexec (Test for syntaxt errors)
# set -n
# identify the unset variables while debugging bash script
# set -u
# debug bash script using xtrace

# set -x
SSID="$1"
INDEX=${2:-0}
SECURITY_TYPE=$3
PASSWORD=${4:-""}

if [[ -z "${SSID}" ]]; then
	echo "Usage: $(/usr/bin/basename "$0") <SSID to remove>"
	exit 1
fi

# Get network hardware port
WifiHardwarePort=$(/usr/sbin/networksetup -listallhardwareports | /usr/bin/awk '/Wi-Fi|AirPort/ {getline; print $NF}')
# Usage: networksetup -addpreferredwirelessnetworkatindex <device name> <network> <index> <security type> [password]
/usr/sbin/networksetup -addpreferredwirelessnetworkatindex ${WifiHardwarePort} "${SSID}" ${INDEX} "${SECURITY_TYPE}" "${PASSWORD}"
