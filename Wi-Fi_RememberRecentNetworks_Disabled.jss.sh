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

# **WARNING:** The airport command line tool is deprecated and will be removed in a future release.
# 
# The airport command-line utility was officially deprecated and stripped of its functionality in macOS Sonoma 14.4.
# While Apple had previously hidden the tool deep within a Private Framework path (/System/Library/PrivateFrameworks/Apple80211.framework/...), the 14.4 update completely disabled the underlying CLI code. 
# Running the command now only returns a deprecation warning.
# **Apple's Recommended Replacements:**
# Apple has broken up the old airport tool functions into two different utilities:
# - For network diagnostics and testing: Use the wdutil command-line tool. Note that for privacy reasons, Apple heavily redacts core Wi-Fi metadata (like BSSIDs) in newer macOS versions.
# - For Wi-Fi configuration and management: Use the standard networksetup utility (as detailed in the previous options).

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

macOSversion=$(sw_vers -productVersion)

echo "macOSversion=${macOSversion}"
# Just get the second version value after 10.
macOSversionMajor=$(echo ${macOSversion} | awk -F. '{print $1}')
macOSversionMinor=$(echo ${macOSversion} | awk -F. '{print $2}')
macOSversionMinorUpdate=$(echo ${macOSversion} | awk -F. '{print $3}')
echo "macOSversionMajor=${macOSversionMajor}"
echo "macOSversionMinor=${macOSversionMinor}"
echo "macOSversionMinorUpdate=${macOSversionMinorUpdate}"


if [[ ${macOSversionMajor} -gt 14 ]] || [[ ${macOSversionMajor} -eq 14 && ${macOSversionMinor} -gt 4 ]]; then
	echo "WARNING: The airport command-line utility was officially deprecated and stripped of its functionality in macOS Sonoma 14.4. Terminating script."
	exit 0
fi

if [[ -x /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport ]]; then
	echo "Wi-Fi (Airport) prefs before..."
	/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport prefs
	echo "Disable Remember Recent Networks"
	/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport prefs RememberRecentNetworks=NO
	sleep 1
	echo "Wi-Fi (Airport) prefs after..."
	/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport prefs
fi

exit 0

