#!/bin/zsh

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
# 2023/02/07:	Creation.
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

# Example:
# /bin/ls -FlOah "${SCRIPTDIR}"

# ###### Usage Documentation #####
# /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport
# 
# Usage: airport <interface> <verb> <options>
# 
# 	<interface>
# 	If an interface is not specified, airport will use the first AirPort interface on the system.
# 
# 	<verb is one of the following:
# 	prefs	If specified with no key value pairs, displays a subset of AirPort preferences for
# 		the specified interface.
# 
# 		Preferences may be configured using key=value syntax. Keys and possible values are specified below.
# 		Boolean settings may be configured using 'YES' and 'NO'.
# 
# 		RememberRecentNetworks (Boolean)
# 
# Examples:
# 
# Configuring preferences (requires admin privileges)
# 	sudo airport en1 prefs JoinMode=Preferred RememberRecentNetworks=NO RequireAdmin=YES
# 
# ##### ------ #####

echo "Wi-Fi (Airport) prefs before..."
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport prefs
echo "Disable Remember Recent Networks"
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport prefs RememberRecentNetworks=NO
sleep 1
echo "Wi-Fi (Airport) prefs after..."
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport prefs

exit 0

