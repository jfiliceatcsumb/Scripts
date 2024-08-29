#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script requires .
# Run it with no arguments. 
# 
# Use as script in Jamf JSS.
# 
####################################################################################################
#
# DESCRIPTION
#
# Automatically download and install GoogleJapaneseInput
#
####################################################################################################
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

echo "pathToScript=$pathToScript"
echo "mountPoint=$mountPoint"
echo "computerName=$computerName"
echo "userName=$userName"

# ##### Debugging flags #####
# debug bash script by enabling verbose “-v” option
# set -v
# debug bash script using noexec (Test for syntaxt errors)
# set -n
# identify the unset variables while debugging bash script
# set -u
# debug bash script using xtrace
# set -x

VendorURL="https://dl.google.com/japanese-ime/latest/GoogleJapaneseInput.dmg"
# Vendor supplied DMG file
VendorDMG="GoogleJapaneseInput.dmg"

dmgVolume="GoogleJapaneseInput"
VendorPKG="GoogleJapaneseInput.pkg"

# https://support.google.com/a/answer/7491144?hl=en&ref_topic=7455083#zippy=%2Cmac
# Run the installer in silent mode:
# hdiutil mount GoogleDrive.dmg; sudo installer -pkg /Volumes/Install\ Google\ Drive/GoogleDrive.pkg -target "/Volumes/Macintosh HD"; hdiutil unmount /Volumes/Install\ Google\ Drive/


# Detatch any previous mounted installer image
if [[ -e /Volumes/"${dmgVolume}"* ]]
then
	for i in /Volumes/"${dmgVolume}"*
	do 
		echo "$i"
		if [[ -d "$i" ]]
		then
			/usr/bin/hdiutil detach "$i" -force
		fi
	done
fi

# Download vendor supplied DMG file into /tmp/
# This prints an error message to stderr
/usr/bin/curl "$VendorURL" --fail --silent --show-error --location --output /tmp/$VendorDMG
# https://dl.google.com/drive-file-stream/GoogleDrive.dmg

# Mount vendor supplied DMG File
/usr/bin/hdiutil attach /tmp/$VendorDMG -nobrowse

# Install
/usr/sbin/installer -pkg "/Volumes/${dmgVolume}/$VendorPKG" -target /

# Unmount the vendor supplied DMG file
for i in /Volumes/"${dmgVolume}"*
do 
	echo "$i"
	if [[ -d "$i" ]]
	then
		/usr/bin/hdiutil detach "$i" -force
	fi
done

# Remove the downloaded vendor supplied DMG file
/bin/rm -f /tmp/$VendorDMG

exit