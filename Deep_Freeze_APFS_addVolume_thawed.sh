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
# Accepts 2 parameters:
# VolumeName dfPassword 
# 
# 
#
####################################################################################################
#
####################################################################################################
#
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

# HARDCODED VALUES SET HERE
dfPassword=""


# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 2 AND, IF SO, ASSIGN TO "DFPASSWORD"
if [ "$2" != "" ] && [ "$dfPassword" == "" ];then
    dfPassword=$2
fi


####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

VolumeName="${1}"

bootDiskdev=$(diskutil info / | awk '/Part of Whole/ {print $4}')

if [ ! -e /Volumes/"$VolumeName" ]
then
	echo "Adding APFS volume $VolumeName..."
	/usr/sbin/diskutil APFS addVolume $bootDiskdev APFS "$VolumeName"
else
	echo "/Volumes/$VolumeName aready exists, thus not creating the APFS volume." 
fi
# ignore permisssions
/usr/sbin/diskutil disableOwnership "/Volumes/$VolumeName"

echo "Setting $VolumeName volume state to Thawed..."
DFXPSWD="$dfPassword" /usr/local/bin/deepfreeze thaw --volume "$VolumeName" --env



exit 0

