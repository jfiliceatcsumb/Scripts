#!/bin/zsh --no-rcs

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script requires one argument: LicenseKey value.
# 
# Use as script in Jamf JSS.

# https://support.techsmith.com/hc/en-us/articles/115007344888-Enterprise-Install-Guidelines-for-Snagit-on-MacOS
# key file path: /Users/Shared/TechSmith/Snagit/LicenseKey
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
echo $LANG
echo "export LANG=en_US.UTF-8"
export LANG=en_US.UTF-8
echo $LANG

LicenseKey="${1}"
/bin/mkdir -pv -m 777 "/Users/Shared/TechSmith/Snagit"
echo "$LicenseKey" > "/Users/Shared/TechSmith/Snagit/LicenseKey"
/bin/chmod -fv 644 "/Users/Shared/TechSmith/Snagit/LicenseKey"
ls -FlOah "/Users/Shared/TechSmith/Snagit"

exit 0

