#!/bin/bash

# Script requires Sophos installer URL passed as Jamf Pro policy parameter #4.
# https://docs.sophos.com/central/Customer/help/en-us/PeopleAndDevices/ProtectDevices/EndpointProtection/MacDeployment/index.html#create-sophos-installation-script

SOPHOS_DIR="/Users/Shared/Sophos_Install"
SOPHOS_INSTALLER_URL=$4
mkdir $SOPHOS_DIR
cd $SOPHOS_DIR

# Installing Sophos
# put installer URL in these quotes
/usr/bin/curl -L -O "$SOPHOS_INSTALLER_URL"
/usr/bin/unzip SophosInstall.zip
/bin/chmod a+x $SOPHOS_DIR/Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer
/bin/chmod a+x $SOPHOS_DIR/Sophos\ Installer.app/Contents/MacOS/tools/com.sophos.bootstrap.helper
/usr/bin/sudo $SOPHOS_DIR/Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer --quiet
/bin/rm -rf $SOPHOS_DIR
exit 0
