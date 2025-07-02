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

# Show secure token status for additional info 
sysadminctl -secureTokenStatus  "${1}"
bootstrap=$(profiles status -type bootstraptoken)
echo $bootstrap
if [[ $bootstrap == *"supported on server: YES"* ]]; then
    if [[ $bootstrap == *"escrowed to server: YES"* ]]; then
		echo "Bootstrap escrowed. Exit script."
    else
		echo "Bootstrap not escrowed."
		echo "Creating the Bootstrap Token APFS record and escrowing to the MDM server..."
        /usr/bin/profiles install -type bootstraptoken -user "${1}" -password "${2}" -verbose
		sleep 1	
		/usr/bin/profiles status -type bootstraptoken
  fi
else
	echo "Bootstrap token not supported on server"
	result="NOT SUPPORTED"
fi

exit 0
