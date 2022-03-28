#!/bin/sh

####################################################################################################
#
# Google Chrome Installation Script
#
####################################################################################################
#
# DESCRIPTION
#
# Automatically download and install Google Chrome
#
####################################################################################################
# 
# HISTORY
#
#
# 2019/08/17:	Forked version, jfilice@csumb.edu
#				Added logic to delete existing /Applications/Google\ Chrome.app
#				Changed cp to ditto.
#				Changed commands to explicite paths.
#
#
# Created by Caine HÃÂ¶rr on 2016-07-25
#
# v1.1 - 2016-10-11 - Caine HÃÂ¶rr
# Added -nobrowse flag to hdiutil attach /tmp/$VendorDMG command line arguments
# Shout out to Chad Brewer (cbrewer) on JAMFNation for this fix/update
# https://jamfnation.jamfsoftware.com/viewProfile.html?userID=1685
#
# v1.0 - 2016-07-25 - Caine HÃÂ¶rr
# Google Chrome Installation script

# Vendor supplied DMG file
VendorDMG="googlechrome.dmg"

# Download vendor supplied DMG file into /tmp/
/usr/bin/curl https://dl.google.com/chrome/mac/stable/GGRO/$VendorDMG -o /tmp/$VendorDMG

# Mount vendor supplied DMG File
/usr/bin/hdiutil attach /tmp/$VendorDMG -nobrowse

# Delete existing target for /Applications/Google\ Chrome.app because it is not a good idea to merge new and old versions.
if [ -e /Applications/Google\ Chrome.app ]; then
	/bin/rm -fR /Applications/Google\ Chrome.app
fi


# Copy contents of vendor supplied DMG file to /Applications/
# Preserve all file attributes and ACLs
/usr/bin/ditto  /Volumes/Google\ Chrome/Google\ Chrome.app /Applications/Google\ Chrome.app
# Set ownership to root:admin
/usr/sbin/chown -fR 0:80 /Applications/Google\ Chrome.app


# Identify the correct mount point for the vendor supplied DMG file 
GoogleChromeDMG="$(hdiutil info | grep "/Volumes/Google Chrome" | awk '{ print $1 }')"

# Unmount the vendor supplied DMG file
/usr/bin/hdiutil detach $GoogleChromeDMG

# Remove the downloaded vendor supplied DMG file
/bin/rm -f /tmp/$VendorDMG
