#!/bin/sh

# Jamf JSS Parameters 1 through 3 are predefined as mount point, computer name, and username

pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3

shift 3
# Shift off the $1 $2 $3 parameters passed by the JSS so that parameter 4 is now $1

####################################################################################################
#
# Modified for Deep Freeze 7 for Mac for APFS-formatted Macs.
#
####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#	Deep_Freeze_APFS_Frozen.sh -- Sets Deep Freeze computer global state to Frozen.
#
# SYNOPSIS
#	sudo Deep_Freeze_APFS_Frozen.sh
#	sudo Deep_Freeze_APFS_Frozen.sh <mountPoint> <computerName> <currentUsername> <dfPassword>
#
# DESCRIPTION
#	This script sets Deep Freeze computer global state to Frozen .  
#	Computer restart is NOT required to Freeze the volumes.

#	This script assumes that the partition to which the machine is currently booted is the working DeepFreeze partition.  
#
#
# If Deep Freeze password is enabled, Deep Freeze password can be
# passed as an environment variable by specifying "--env".
# Usage:
# DFXPSWD=password /usr/local/bin/deepfreeze <command> <verb> argument [option] --env
# 
# 
####################################################################################################
#
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

# HARDCODED VALUES SET HERE
dfPassword=""


# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 5 AND, IF SO, ASSIGN TO "DFPASSWORD"
if [ "$1" != "" ] && [ "$dfPassword" == "" ];then
    dfPassword=$1
fi

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

if [ "dfPassword" != "" ];then
  echo "Setting Deep Freeze computer global state to Frozen..."
  DFXPSWD="$dfPassword" /usr/local/bin/deepfreeze freeze --computer --env
else
  echo "Setting Deep Freeze computer global state to Frozen..."
  /usr/local/bin/deepfreeze freeze --computer

fi

echo "See the status of Deep Freeze..."
/usr/local/bin/deepfreeze status


exit 0
