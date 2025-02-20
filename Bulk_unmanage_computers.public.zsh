#!/bin/zsh --no-rcs

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it


# https://community.jamf.com/t5/jamf-pro/bulk-unmanage-computers/m-p/307595/highlight/true#M268354


SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTDIR=`/usr/bin/dirname "$0"`

# ################### Variables ###################
url="" # https://yourserver.jamfcloud.com
client_id="" # your-client-id
client_secret="" # yourClientSecret

# Paste in a list of Mac SNs to be removed from management:
# Create an empty array to store the data
unmanage_array=()
unmanage_array=(
SN#####
SN#####
SN#####
)
# ################### ###################


getAccessToken() {
	response=$(curl --silent --location --request POST "${url}/api/oauth/token" \
 	 	--header "Content-Type: application/x-www-form-urlencoded" \
 		--data-urlencode "client_id=${client_id}" \
 		--data-urlencode "grant_type=client_credentials" \
 		--data-urlencode "client_secret=${client_secret}")
 	access_token=$(echo "$response" | plutil -extract access_token raw -)
 	token_expires_in=$(echo "$response" | plutil -extract expires_in raw -)
 	token_expiration_epoch=$(($current_epoch + $token_expires_in - 1))
}

checkTokenExpiration() {
 	current_epoch=$(date +%s)
    if [[ token_expiration_epoch -ge current_epoch ]]
    then
        echo "Token valid until the following epoch time: " "$token_expiration_epoch"
    else
        echo "No valid token available, getting new token"
        getAccessToken
    fi
}

invalidateToken() {
	responseCode=$(curl -w "%{http_code}" --header "Authorization: Bearer ${access_token}" $url/api/v1/auth/invalidate-token --request POST -s -o /dev/null)
	if [[ ${responseCode} == 204 ]]
	then
		echo "Token successfully invalidated"
		access_token=""
		token_expiration_epoch="0"
	elif [[ ${responseCode} == 401 ]]
	then
		echo "Token already invalid"
	else
		echo "An unknown error occurred invalidating the token"
	fi
}

# Read the CSV file line by line
readCSVtoArray() {
while read line; do
  # Split the line into an array using comma as the delimiter
  row=(${(s:,:)line})

  # Append the row to the data array
  unmanage_array+=($row)
done < "$csv_file"
}



# ##### Debugging flags #####
# debug bash script by enabling verbose “-v” option
# set -v
# debug bash script using noexec (Test for syntaxt errors)
# set -n
# identify the unset variables while debugging bash script
# set -u
# debug bash script using xtrace
# set -x

# This can't be run from Jamf. We're just storing it here.
# Download it to your Mac and run it in Terminal.
 
date

if [[ "${url}" = "" ]] ||  [[ "${client_id}" = "" ]]  || [[ "${client_secret}" = "" ]]; then
	echo "Enter JSS URL (with port # if not 443)"
	echo "e.g. https://mycompany.jamfcloud.com:443"
	echo "URL:"
	read url
	echo "API client ID:"
	read client_id
	echo "API client secret:"
	read -s client_secret
	echo "Enter file path to CSV file with list of Mac serial numbers to be removed from management:"
	read csv_file
fi
checkTokenExpiration
curl --header "Authorization: Bearer ${access_token}" $url/api/v1/jamf-pro-version --request GET
checkTokenExpiration

readCSVtoArray

for SERIAL in ${unmanage_array[@]}
do
 	checkTokenExpiration
	# This next commented code is to get the serial number of the Mac from which the script 
	# is running in the case of performing the script on this local Mac to remove it from management.
	# I've turned it off in favour of using an array of provided SNs of other Macs. See above.
	# to remove from management.
	 
	# Get local serial number:
	 
	# SERIAL=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
	# /bin/echo "Serial number is $SERIAL"
	 
	# Get JAMF ID of device from API looked by SN found locally or provided in
	# $unmanage_array array:
	JAMF_ID=$(curl --request GET "${url}/JSSResource/computers/serialnumber/$SERIAL" --header "accept: application/xml" --header "Authorization: Bearer ${access_token}" | xmllint --xpath '/computer/general/id/text()' -)
	 
	# API call to de-select "Allow Jamf Pro to perform management tasks" in the JSS for this device:
	curl --request PUT --url "${url}/JSSResource/computers/id/$JAMF_ID" --header "Content-Type: application/xml" --header "Accept: application/xml" --header "Authorization: Bearer ${access_token}" --data '<computer><general><remote_management><managed>false</managed></remote_management></general></computer>'
	echo 
	/bin/echo "JAMF ID for $SERIAL is $JAMF_ID and it is now unmanaged in the JSS"
done
# ##### LOOP DONE #####
 
/bin/echo "Invalidating API token..."
invalidateToken
/bin/echo "Confirm API token invalidated..."
curl --header "Authorization: Bearer ${access_token}" $url/api/v1/jamf-pro-version --request GET
 
/bin/echo "Done."
date
exit 0

