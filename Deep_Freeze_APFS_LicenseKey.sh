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
#	Deep_Freeze_APFS_LicenseKey.sh
#
# SYNOPSIS
#	sudo Deep_Freeze_APFS_LicenseKey.sh <LicenseKey>
#
# DESCRIPTION
#	This script activates Deep Freeze Mac with a license key.  
#
# 
# 
# 
####################################################################################################
#
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################


####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################
dfLicenseKey="$1"

if [ "$dfLicenseKey" == "" ];then
	echo "Error:  The parameter 'dfLicenseKey' is blank.  Please specify a Deep Freeze License Key."
	exit 1
fi


echo "Activating Deep Freeze Mac with a license key..."
/usr/local/bin/deepfreeze  license --set $dfLicenseKey

echo "See the status of Deep Freeze..."
/usr/local/bin/deepfreeze  license --info


exit 0