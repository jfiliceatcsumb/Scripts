#!/bin/bash


# Script to add a directory user group (e.g. from Active Directory) to a Mac's ard_interact group.
# Also enables ard_interact group and ARD client directory logins.
# This has been tested with macOS 10.13 and 10.14.
# 

##################
# Edit variables in this section
# 
# User directory group to add to ard_interact. 
addARDgroup="MyDomain\Domain Users"
# 
##################

KICKSTART="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"

# test if ard_interact group exists already
test_ard_interact=$(/usr/sbin/dseditgroup ard_interact) 2>/dev/null
# If $test_ard_interact string is emtpy, the group does not exist.
if [ -z "$test_ard_interact" ] 
then
	echo "ard_interact group not found. Creating ard_interact group..."
	
	/usr/sbin/dseditgroup -v -o create -r "ARD Interact" -c "ARD Interact group for directory-based authentication." ard_interact
else
	echo "The ard_interact group already exists. Continuing..."

fi

echo "======================="
echo "Adding $addARDgroup group to ard_interact group..."
/usr/sbin/dseditgroup -v -o edit -a "$addARDgroup" -t group ard_interact

echo "======================="
echo "Displaying $addARDgroup group info..."
/usr/sbin/dseditgroup -o read "$addARDgroup"

echo "======================="
echo "Enabling directory logins for Apple Remote Desktop client..."
$KICKSTART -verbose -configure -clientopts -setdirlogins -dirlogins yes

exit
