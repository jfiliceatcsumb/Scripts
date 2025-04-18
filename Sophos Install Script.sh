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


SOPHOS_DIR=$(/usr/bin/mktemp -d -t Sophos_Install)
SOPHOS_INSTALLER_URL=$1
# Sanitize by deleting this temporary directory at the beginning if it already exists. 
# Unfortunately, this script does not do any checksum of the Sophos installer, so this is helps mitigate the risk.
if [[ -e "${SOPHOS_DIR}" ]]; then
	/bin/rm -rf "${SOPHOS_DIR}"
fi

trap '/bin/rm -rf ${SOPHOS_DIR}' EXIT
cd $SOPHOS_DIR


echo "Installing Sophos..."
# put installer URL in these quotes
# curl specify output file to the same as expected in the script. The URL could change and break things.
/usr/bin/curl --output SophosInstall.zip --location "$SOPHOS_INSTALLER_URL"
/usr/bin/unzip SophosInstall.zip
/bin/chmod a+x $SOPHOS_DIR/Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer
/bin/chmod a+x $SOPHOS_DIR/Sophos\ Installer.app/Contents/MacOS/tools/com.sophos.bootstrap.helper
$SOPHOS_DIR/Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer --quiet

echo "Removing Sophos installer..."

/bin/rm -rf "${SOPHOS_DIR}"

# Removing this step because the updater fails until full reboot. Simply allow it to update per normal scheudule.
# echo "Waiting 5 minutes before updating Sophos..."
# # 60 seconds does not seem to be enough time. Still getting results: 'Failed to request update'
# # Increasing the wait time.
# sleep 300
# echo "Run Sophos AutoUpdate Tool..."
# /usr/local/bin/RunSophosUpdate
# https://community.sophos.com/free-tools/f/discussions/7419/mac-terminal-update-and-running-options

echo "Read Sophos product info..."
/usr/bin/defaults read "/Library/Sophos Anti-Virus/product-info.plist"

exit


# #####################
# Install Sophos Script.txt
# 2024-Mar-27
# Included with Sophos Installer.app v.1.7.0
# #####################
# #!/bin/bash
# SOPHOS_DIR=$(mktemp -d -t Sophos_Install)
# trap 'rm -rf ${SOPHOS_DIR}' EXIT
# cd $SOPHOS_DIR
# 
# # Installing Sophos
# curl -L -O "put installer URL in these quotes."
# unzip SophosInstall.zip
# chmod a+x $SOPHOS_DIR/Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer
# chmod a+x $SOPHOS_DIR/Sophos\ Installer.app/Contents/MacOS/tools/com.sophos.bootstrap.helper
# $SOPHOS_DIR/Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer --quiet
# rm -rf $SOPHOS_DIR
# exit 0
