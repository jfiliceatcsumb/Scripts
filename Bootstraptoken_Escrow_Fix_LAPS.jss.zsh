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

# Add parameter validation
if [[ -z "${1}" ]] || [[ -z "${2}" ]]; then
    echo "Error: Volume owner account and password are required"
    exit 1
fi



# Show secure token status for additional info 
/usr/sbin/sysadminctl -secureTokenStatus  "${1}"
echo "Check Bootstrap Token status..."
bootstrap=$(/usr/bin/profiles status -type bootstraptoken)
echo ${bootstrap}
if [[ $bootstrap == *"supported on server: YES"* ]]; then
    if [[ $bootstrap == *"escrowed to server: YES"* ]]; then
		echo "Bootstrap escrowed. Exit script."
    else
		echo "Bootstrap not escrowed."
		echo "Creating the Bootstrap Token APFS record and escrowing to the MDM server..."
# 		Used to verify the password
# 		authenticate the account without actually logging into anything
# 		account authenticates in any way it will have a SecureToken enabled on the account
		if ! /usr/bin/dscl . authonly "${1}" "${2}"; then
			echo "Error: Authentication failed"
			exit 1
		fi
		sleep 1
		# Add error handling for profiles command
		if ! /usr/bin/profiles install -type bootstraptoken -user "${1}" -password "${2}" -verbose; then
			echo "Error: Failed to install bootstrap token"
			exit 1
		fi
		sleep 1	
		/usr/bin/profiles status -type bootstraptoken
  fi
else
	echo "Bootstrap token not supported on server"
	result="NOT SUPPORTED"
fi

exit 0
