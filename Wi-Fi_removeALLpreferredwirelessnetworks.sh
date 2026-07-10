#!/bin/zsh --no-rcs

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Run it with one argument, string name of the wi-fi SSID to remove from preferred wireless networks. 
# 
# Use as script in Jamf JSS.


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


for interface in $(networksetup -listnetworkserviceorder | grep -e "Hardware" | grep -e "Wi-Fi" |  sed -e 's/(//'  -e  's/)//' | awk '{ print $NF }')
do  
	echo "Remove all networks from the preferred wireless network list for $interface"  
	/usr/sbin/networksetup -removeallpreferredwirelessnetworks $interface
done

exit 0
