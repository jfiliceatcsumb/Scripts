#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it




# Script requires Sophos installer URL passed as Jamf Pro policy parameter #4.
# https://docs.sophos.com/central/Customer/help/en-us/PeopleAndDevices/ProtectDevices/EndpointProtection/MacDeployment/index.html#create-sophos-installation-script


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


SOPHOS_DIR="/Users/Shared/Sophos_Install"
SOPHOS_INSTALLER_URL=$1
# Sanitize by deleting this directory at the beginning if it already exists. 
# Unfortunately, this script does not do any checksum of the Sophos installer, so this is critical.
/bin/rm -rf $SOPHOS_DIR
/bin/mkdir $SOPHOS_DIR
cd $SOPHOS_DIR

echo "Installing Sophos..."
# put installer URL in these quotes
# curl specify output file to the same as expected in the script. The URL could change and break things.
/usr/bin/curl --output SophosInstall.zip -L -O "$SOPHOS_INSTALLER_URL"
/usr/bin/unzip SophosInstall.zip
/bin/chmod a+x $SOPHOS_DIR/Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer
/bin/chmod a+x $SOPHOS_DIR/Sophos\ Installer.app/Contents/MacOS/tools/com.sophos.bootstrap.helper
/usr/bin/sudo $SOPHOS_DIR/Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer --quiet

echo "Removing Sophos installer..."

/bin/rm -rf $SOPHOS_DIR

echo "Waiting 60 seconds before updating Sophos..."
sleep 60
echo "Run Sophos AutoUpdate Tool..."
/usr/local/bin/RunSophosUpdate
# https://community.sophos.com/free-tools/f/discussions/7419/mac-terminal-update-and-running-options

echo "Read Sophos product info..."
/usr/bin/defaults read "/Library/Sophos Anti-Virus/product-info.plist"

exit
