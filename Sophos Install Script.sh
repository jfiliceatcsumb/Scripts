#!/bin/bash
SOPHOS_DIR="/Users/Shared/Sophos_Install"
mkdir $SOPHOS_DIR
cd $SOPHOS_DIR

# Installing Sophos
curl -L -O "put installer URL in these quotes."
unzip SophosInstall.zip
chmod a+x $SOPHOS_DIR/Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer
chmod a+x $SOPHOS_DIR/Sophos\ Installer.app/Contents/MacOS/tools/com.sophos.bootstrap.helper
sudo $SOPHOS_DIR/Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer --quiet
rm -rf $SOPHOS_DIR
exit 0
