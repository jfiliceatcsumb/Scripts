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
# 2024/04/19:	Creation.
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

# set alias for PlistBuddy and several others so I don't have to specify full path.
# Prefix sudo path because I'm using it here for all commands.
# If I want to run a command without the alias, then specify the full path.

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

# Get the OS on the Mac
OS_Build=$( /usr/bin/sw_vers --buildVersion )

# Check if the OS matches our logged one, do a recon if it doesn't.
if [ -f /var/log/os_build.log ]; then
    Recorded_Version=$( cat /var/log/os_build.log )
    if ! [ ${Recorded_Version} == ${OS_Build} ]; then
        /usr/local/bin/jamf recon
        echo ${OS_Build} > /var/log/os_build.log
    else
        echo "This Mac has rebooted but no OS change found. No recon necessary."
    fi
else
    echo ${OS_Build} > /var/log/os_build.log
fi

exit 0

