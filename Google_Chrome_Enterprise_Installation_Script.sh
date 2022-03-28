#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it
# 
####################################################################################################
#
# Google Chrome Enterprise Installation Script
#
####################################################################################################
#
# DESCRIPTION
#
# Automatically download and install Google Chrome Enterprise pkg
#
####################################################################################################
#
# Run it with no arguments. 
# 
# Use as script in Jamf JSS.
# 
# Change History:
# 2022/03/28:	Creation.
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



PKGfile="GoogleChrome.pkg"
PKG_URL="https://dl.google.com/dl/chrome/mac/universal/stable/gcem/GoogleChrome.pkg"

# Download vendor supplied PKG file into /tmp/
/usr/bin/curl "$PKG_URL" --location --create-dirs --output /tmp/"$PKGfile"

sleep 1

# Install
/usr/sbin/installer -allow -pkg "/tmp/$PKGfile" -target /

sleep 1

# Remove the downloaded pkg
if [[ -e /tmp/"$PKGfile" ]]; then
	rm -fR /tmp/"$PKGfile"
fi

