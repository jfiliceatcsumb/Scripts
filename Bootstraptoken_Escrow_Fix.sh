#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it
#
# This script requires a supervised Mac managed by MDM server.
# Run it with 2 arguments:
# volume owner account
# volume owner password
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
# debug bash script by enabling verbose "-v" option
# set -v
# debug bash script using noexec (Test for syntaxt errors)
# set -n
# identify the unset variables while debugging bash script
# set -u
# debug bash script using xtrace
# set -x

bootstrap_is_supported() {
    echo "$1" | grep -q "supported on server: YES"
}

bootstrap_is_escrowed() {
    echo "$1" | grep -q "escrowed to server: YES"
}

check_not_macOS26Tahoe() {
	# Get the current macOS version
	currentVersion=$(/usr/bin/sw_vers -productVersion)
	
	# Extract major version (first number before the first dot)
	majorVersion=${currentVersion%%.*}
	
	# Check if major version is less than 26
	# Return 0 (success/true) if NOT version 26 or higher
	# Return 1 (failure/false) if version is 26 or higher
	if (( majorVersion < 26 )); then
		return 0
	else
		echo "Warning: macOS $currentVersion (26.0 or higher) detected. Skipping bootstrap token update."
		return 1
	fi
}

verify_authentication() {
# 		Used to verify the password
# 		authenticate the account without actually logging into anything
# 		account authenticates in any way it will have a SecureToken enabled on the account
	if ! /usr/bin/dscl . authonly "${1}" "${2}"; then
		echo "Error: Authentication failed"
		exit 1
	fi
	sleep 0.1
}

escrow_bootstraptoken() {
# Add error handling for profiles command
	verify_authentication "${1}" "${2}"
	if ! /usr/bin/profiles install -type bootstraptoken -user "${1}" -password "${2}" -verbose; then
		echo "Error: Failed to install bootstrap token"
		exit 1
	fi
	sleep 0.1	
	/usr/bin/profiles status -type bootstraptoken
}


#  parameter validation
if [[ -z "${1}" ]] || [[ -z "${2}" ]]; then
    echo "Error: Volume owner account and password are required"
    exit 1
fi


echo "Show secure token status for additional info..." 
/usr/sbin/sysadminctl -secureTokenStatus  "${1}"
echo "Show Bootstrap Token status..."
bootstrap=$(/usr/bin/profiles status -type bootstraptoken)

echo ${bootstrap}

# Then use them:
if bootstrap_is_supported "$bootstrap"; then
	if bootstrap_is_escrowed "$bootstrap"; then
    	echo "Bootstrap escrowed..."
			if check_not_macOS26Tahoe; then
				echo "Updating the Bootstrap Token APFS record and escrowing to the MDM server..."
				escrow_bootstraptoken "${1}" "${2}"
			fi
    else
			echo "Bootstrap not escrowed."
			echo "Creating the Bootstrap Token APFS record and escrowing to the MDM server..."
			escrow_bootstraptoken "${1}" "${2}"
    fi
	fi
else
	echo "Bootstrap token not supported on server"
	result="NOT SUPPORTED"
fi

exit 0
