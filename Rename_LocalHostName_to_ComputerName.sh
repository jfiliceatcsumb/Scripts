#!/bin/bash

# Credit: https://www.jamf.com/jamf-nation/articles/148/updating-the-computer-name-of-managed-computers


# get Computer Name
computerName=$( /usr/sbin/scutil --get ComputerName )
echo "Computer Name: $computerName"

# create network name using only alphanumeric characters and hyphens for spaces
networkName=$( /usr/bin/sed -e 's/ /-/g' -e 's/[^[:alnum:]-]//g' <<< "$computerName" )
echo "Network Name: $networkName"

# set hostname and local hostname
/usr/sbin/scutil --set HostName "$networkName"
/usr/sbin/scutil --set LocalHostName "$networkName"

exit 0
echo HostName:  $(/usr/sbin/scutil --get HostName)

echo LocalHost Name:  $(/usr/sbin/scutil --get LocalHostName)

echo Computer Name: $(/usr/sbin/scutil --get ComputerName)


/usr/sbin/bless --info --getBoot 

# set +x


echo "***End $SCRIPTNAME script***"
/bin/date

exit 0
