#!/bin/bash

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
set -x

# Vendor supplied DMG file
VendorDMG="GoogleDrive.dmg"

GoogleDriveVolume="Install Google Drive"


# https://support.google.com/a/answer/7491144?hl=en&ref_topic=7455083#zippy=%2Cmac
# Run the installer in silent mode:
# hdiutil mount GoogleDrive.dmg; sudo installer -pkg /Volumes/Install\ Google\ Drive/GoogleDrive.pkg -target "/Volumes/Macintosh HD"; hdiutil unmount /Volumes/Install\ Google\ Drive/


# Detatch any previous mounted installer image
for i in /Volumes/"${GoogleDriveVolume}"*
do 
	echo "$i"
	if [[ -d "$i" ]]
	then
		/usr/bin/hdiutil detach "$i" -force
	fi
done


# Download vendor supplied DMG file into /tmp/
/usr/bin/curl "https://dl.google.com/drive-file-stream/$VendorDMG" --location --output /tmp/$VendorDMG
# https://dl.google.com/drive-file-stream/GoogleDrive.dmg

# Mount vendor supplied DMG File
/usr/bin/hdiutil attach /tmp/$VendorDMG -nobrowse


# Identify the correct mount point for the vendor supplied DMG file 
# GoogleDriveFileStreamDMG="$(/usr/bin/hdiutil info | grep "/Volumes/$GoogleDriveVolume" | awk '{ print $1 }')"

# Install
/usr/sbin/installer -pkg "/Volumes/$GoogleDriveVolume/GoogleDrive.pkg" -target /

# Unmount the vendor supplied DMG file
for i in /Volumes/"${GoogleDriveVolume}"*
do 
	echo "$i"
	if [[ -d "$i" ]]
	then
		/usr/bin/hdiutil detach "$i" -force
	fi
done

# Remove the downloaded vendor supplied DMG file
/bin/rm -f /tmp/$VendorDMG
