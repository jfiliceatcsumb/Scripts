#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it


# Moves /Applications/zoom.us.app into the User Template folder. 
# This ensures that the zoomu.us.app is created in new users proviles in their home directories
# 	and enables them to update without admin privileges. 
# 	This is especially useful on shared/lab Macs where multiple users will log in.
# 
# This script requires /Applications/zoom.us.app is already installed. 
# Best to install Zoom first with https://zoom.us/client/latest/ZoomInstallerIT.pkg
# Run it with no arguments. 
# 
# Use as script in Jamf JSS.


# Change History:
# 2022/07/02:	Creation.
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

echo pathToScript=$pathToScript
echo mountPoint=$mountPoint
echo computerName=$computerName
echo userName=$userName



# Example:
# /bin/ls -FlOah "${SCRIPTDIR}"
source_ZoomApp="/Applications/zoom.us.app"
target_User_Template="/Library/User Template/Non_localized"
target_ZoomApp="$target_User_Template/Applications/zoom.us.app"

if [[ -z "$source_ZoomApp" ]];then
	echo "Error: $source_ZoomApp not found. Exiting script."
	exit 1
fi

# Delete any existing app at target location to avoid strange merging issues.
if [[ -e "$target_ZoomApp" ]]; then
	/bin/rm -frv "$target_ZoomApp"
fi
/bin/mkdir -pv -m 755 "$target_User_Template/Applications"
/usr/sbin/chown -vf 0:0 "$target_User_Template/Applications"
/bin/mv -fv "$source_ZoomApp" "$target_ZoomApp"
/usr/sbin/chown -vfR 0:0 "$target_ZoomApp"
/bin/chmod  -vfR 755 "$target_ZoomApp"

exit 0

