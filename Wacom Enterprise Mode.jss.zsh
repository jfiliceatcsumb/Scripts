#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it

# Run it with no arguments. 
# Use as script in Jamf JSS.

##################################
#
# Enable Wacom Enterprise Mode
# Written by KClose
#
# This script creates a file to force Enterprise Mode for all Wacom Tablet drivers.
#	This should function on any Wacom drivers from version 6.4.4 and up.
#
##################################
# https://community.jamf.com/t5/jamf-pro/how-to-disable-auto-launching-quot-wacom-desktop-center-quot-app/m-p/324055/highlight/true#M278697

### VARIABLES ###
scriptFile="/Library/Preferences/com.wacomtablet.defaults.xml"

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

### MAIN SCRIPT ###
# Create file.
echo "Writing script file."
touch "$scriptFile"
/usr/bin/printf '<?xml version="1.0" encoding="utf-8"?>
<!--Author: Wacom Co.,Ltd.-->
<root>
	<!-- Set Enterprise Mode -->
	<OperatingMode>Enterprise</OperatingMode>
</root>' > "$scriptFile"

# Set ownership and permissions.
echo "Setting ownership and permissions on script file."
chown -R 0:0 "$scriptFile"
chmod -R 755 "$scriptFile"


exit 0

