#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script downloads and installs the current "Download for IT Admin" Zoom Client for Meetings from zoom.us.
# Run it with no arguments. 
# 
# For best results, copy it to the Mac and run it as postinstall script in a PKG installer.


# Change History:
# 2020/06/04:	Creation.
# 2021/06/09:	Added flag -allow to installer
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

echo "Start $SCRIPTNAME"

# set -x

PKGfile="ZoomInstallerIT.pkg"
PKG_URL="https://zoom.us/client/latest/ZoomInstallerIT.pkg"

if [ -e /tmp/"$PKGfile" ]; then
	rm -fR /tmp/"$PKGfile"
fi

# Download vendor pkg file into /tmp/
# This prints an error message to stderr
/usr/bin/curl "$PKG_URL" --fail --silent --show-error --location --create-dirs --output /tmp/"$PKGfile"

sleep 1

# Install
/usr/sbin/installer -allow -pkg "/tmp/$PKGfile" -target /

sleep 1

# Remove the downloaded pkg
if [[ -e /tmp/"$PKGfile" ]]; then
	rm -fR /tmp/"$PKGfile"
fi

echo "End $SCRIPTNAME"
