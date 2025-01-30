#!/bin/zsh --no-rcs

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it


# https://community.jamf.com/t5/jamf-pro/bulk-unmanage-computers/m-p/307595/highlight/true#M268354

# Change History:
# 2022/MM/DD:	Creation.
#

SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTDIR=`/usr/bin/dirname "$0"`

# ################### Variables ###################
URL="https://k400-1a.pro.jamf.training"
client_id=""
client_secret=""

# Paste in a list of Mac SNs to be removed from management:
unmanage=(
SN#####
SN#####
SN#####
)
# ################### ###################

# set alias for PlistBuddy and several others so I don't have to specify full path.
# Prefix sudo path because I'm using it here for all commands.
# If I want to run a command without the alias, then specify the full path.
alias PlistBuddy="/usr/libexec/PlistBuddy"
alias chown="/usr/sbin/chown"
alias chmod="/bin/chmod"
alias ditto="/usr/bin/ditto"
alias defaults="/usr/bin/defaults"
alias rm="/bin/rm"
alias cp="/bin/cp"
alias mkdir="/bin/mkdir"
alias sudo=/usr/bin/sudo

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
 
echo "Enter JSS URL (with port # if not 443)"
echo "e.g. https://mycompany.jamfcloud.com:443"
echo "URL:"
read URL
echo "Enter JSS username:"
read USERNAME
echo "Enter JSS password:"
read -s PASSWORD
 
TOKEN_EXPIRATION_EPOCH="0"


for SERIAL in ${unmanage[@]}
do
 
# This next commented code is to get the serial number of the Mac from which the script 
# is running in the case of performing the script on this local Mac to remove it from management.
# I've turned it off in favour of using an array of provided SNs of other Macs. See above.
# to remove from management.
 
# Get local serial number:
 
# SERIAL=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
# /bin/echo "Serial number is $SERIAL"
 
# Get JAMF ID of device from API looked by SN found locally or provided in
# $unmanage array:
JAMF_ID=$(curl -X GET "${URL}/JSSResource/computers/serialnumber/$SERIAL" -H "accept: application/xml" -H "Authorization: Bearer $BEARER_TOKEN" | xmllint --xpath '/computer/general/id/text()' -)
 
# API call to de-select "Allow Jamf Pro to perform management tasks" in the JSS for this device:
curl --request PUT --url "${URL}/JSSResource/computers/id/$JAMF_ID" -H "Content-Type: application/xml" -H "Accept: application/xml" -H "Authorization: Bearer $BEARER_TOKEN" -d '<computer><general><remote_management><managed>false</managed></remote_management></general></computer>'
 
/bin/echo "JAMF ID for $SERIAL is $JAMF_ID and it is now unmanaged in the JSS"
done
 
# Bin the token
/bin/echo "Invalidating API token..."
invalidateToken
 
/bin/echo "Done."
 
exit 0

