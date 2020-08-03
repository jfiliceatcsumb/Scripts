#!/bin/sh

# Script to remove a directory user group (e.g. from Active Directory) from a Mac's ard_interact group.
# Also enables ard_interact group and ARD client directory logins.
# This has been tested with macOS 10.13 and 10.14.

##################
# Edit variables in this section
# 
# User directory group to remove from ard_interact. 
addARDgroup="CSUMB\Domain Users"
# 
##################

# test if ard_interact group exists already
test_ard_interact=$(/usr/sbin/dseditgroup ard_interact) 2>/dev/null
# If $test_ard_interact string is emtpy, the group does not exist.
if [ -z "$test_ard_interact" ] 
then
	echo "The ard_interact group not found. Exiting..."
    exit

else

    echo "ard_interact group found. Removing $addARDgroup Users group from ard_interact group..."
    /usr/sbin/dseditgroup -v -o edit -d "$addARDgroup" -t group ard_interact

fi


exit
