#!/bin/sh

####################################################################################################
#
# Google_Drive_File_Stream_Installation_Script
#
####################################################################################################
#
# DESCRIPTION
#
# Automatically download and install Google Drive File Stream
#
####################################################################################################
# 

# Vendor supplied DMG file
VendorDMG="GoogleDriveFileStream.dmg"

GoogleDriveFileStreamVolume="Install Google Drive File Stream"



# Detatch any previous mounted installer image
GoogleDriveFileStreamDMG="$(/usr/bin/hdiutil info | grep "/Volumes/$GoogleDriveFileStreamVolume" | awk '{ print $1 }')"
if [ -n "$GoogleDriveFileStreamDMG" ]; then
  /usr/bin/hdiutil detach $GoogleDriveFileStreamDMG
fi

# Reset value
GoogleDriveFileStreamDMG=""

# Download vendor supplied DMG file into /tmp/
/usr/bin/curl https://dl.google.com/drive-file-stream/$VendorDMG -o /tmp/$VendorDMG

# hdiutil mount GoogleDriveFileStream.dmg; sudo installer -pkg /Volumes/Install\ Google\ Drive\ File\ Stream/GoogleDriveFileStream.pkg -target "/Volumes/Macintosh HD"; hdiutil unmount /Volumes/Install\ Google\ Drive\ File\ Stream/

# Mount vendor supplied DMG File
/usr/bin/hdiutil attach /tmp/$VendorDMG -nobrowse


# Identify the correct mount point for the vendor supplied DMG file 
GoogleDriveFileStreamDMG="$(/usr/bin/hdiutil info | grep "/Volumes/$GoogleDriveFileStreamVolume" | awk '{ print $1 }')"

# Install
# Preserve all file attributes and ACLs
/usr/sbin/installer -pkg "/Volumes/$GoogleDriveFileStreamVolume/GoogleDriveFileStream.pkg" -target /

# Unmount the vendor supplied DMG file
/usr/bin/hdiutil detach $GoogleDriveFileStreamDMG

# Remove the downloaded vendor supplied DMG file
/bin/rm -f /tmp/$VendorDMG
