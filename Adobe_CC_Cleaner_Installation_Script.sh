#!/bin/sh

####################################################################################################
#
# Install Adobe Creative Cloud Cleaner Tool.app
#
####################################################################################################
#
# DESCRIPTION
#
# Automatically download and install Adobe Creative Cloud Cleaner Tool.app
#
####################################################################################################
# 
# https://helpx.adobe.com/creative-cloud/kb/cc-cleaner-tool-installation-problems.html#run_cc_cleaner_tool_for_mac
# 
# VendorDMG
VendorDMG="AdobeCreativeCloudCleanerTool.dmg"


# Download vendor supplied DMG file into /tmp/
/usr/bin/curl --location https://swupmf.adobe.com/webfeed/CleanerTool/mac/$VendorDMG -o /tmp/$VendorDMG

/usr/bin/hdiutil detach /Volumes/CleanerTool/

# Mount vendor supplied DMG File
/usr/bin/hdiutil attach /tmp/$VendorDMG -nobrowse

# Delete existing target for /Applications/Google\ Chrome.app because it is not a good idea to merge new and old versions.
if [ -e /Applications/Utilities/"Adobe Creative Cloud Cleaner Tool.app" ]; then
	/bin/rm -fR /Applications/Utilities/"Adobe Creative Cloud Cleaner Tool.app"
fi


# Copy contents of vendor supplied DMG file to /Applications/
# Preserve all file attributes and ACLs
/usr/bin/ditto  /Volumes/CleanerTool/"Adobe Creative Cloud Cleaner Tool.app" /Applications/Utilities/"Adobe Creative Cloud Cleaner Tool.app"
# Set ownership to root:admin
/usr/sbin/chown -fR 0:80 /Applications/Utilities/"Adobe Creative Cloud Cleaner Tool.app"


# Identify the correct mount point for the vendor supplied DMG file 
MountpointDMG="$(hdiutil info | grep "/Volumes/CleanerTool" | awk '{ print $1 }')"

# Unmount the vendor supplied DMG file
/usr/bin/hdiutil detach $MountpointDMG

# Remove the downloaded vendor supplied DMG file
/bin/rm -f /tmp/$VendorDMG

exit
