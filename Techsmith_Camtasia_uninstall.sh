﻿#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script deletes previous Camtasia installs, if present.
# Run this script as stand-alone uninstaller or as a pre-install step for Camtasia installations.
# Run it with no arguments. 
# 
# Use as script in Jamf JSS.


# Change History:
# 2021/02/16:	Creation.
#

SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

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


# Example:
# /bin/ls -FlOah "${SCRIPTPATH}"


echo "Closing previous Camtasia installs (if present)..."
/usr/bin/find "/Applications" -name "Camtasia*.app" -type d -maxdepth 1 -exec /usr/bin/killall {} \;

echo "Deleting previous Camtasia installs (if present)..."
/usr/bin/find "/Applications" -name "Camtasia*.app" -type d -maxdepth 1 -exec rm -rfv {} \;

exit 0

