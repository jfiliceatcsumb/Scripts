#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Uninstall script for Blackmagic DaVinci Resolve 12.x (and Studio).
# Using code in script from Resolve 12.5 uninstall application.
# /Volumes/Blackmagic DaVinci Resolve/Uninstall Resolve.app/Contents/Resources/uninstall.sh
# 
# Postponed script execution in DeployStudio. Commands must run as root.

# Change History:
# 2016/06/15:	Creation.
# 2016/07/14:	Added if-then to check for existence of files. If Resolve is not already installed, then the files don't exist, thus we want to skip the uninstall. Otherwise, DeployStudio could retry the script at the end of the workflow, thus removing the version of Resolve we want to keep. 
# 2018/08/17:	Added "Panels" section from Resolve 14.3 uninstall.sh
#


SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

echo "***Begin $SCRIPTNAME script***"
/bin/date

##### vvvvv Borrowed code starts here vvvvv #####

# unconfigure panel
if [ -e "/Library/Application Support/Blackmagic Design/DaVinci Resolve/configure-panel.sh" ]
then
	"/Library/Application Support/Blackmagic Design/DaVinci Resolve/configure-panel.sh" none
fi

# unconfigure dp

if [ -e "/Library/Application Support/Blackmagic Design/DaVinci Resolve/configure-dp.sh" ]
then
	"/Library/Application Support/Blackmagic Design/DaVinci Resolve/configure-dp.sh" off
fi

# application support and prefs
/bin/rm -rf "/Library/Application Support/Blackmagic Design/DaVinci Resolve/"
/bin/rm -rf "/Library/Preferences/Blackmagic Design/DaVinci Resolve/"

# Application
/bin/rm -rf "/Applications/DaVinci Resolve.app"
/bin/rm -rf "/Applications/DaVinci Resolve/"

# Panels
/bin/rm -rf "/Library/Frameworks/DaVinciPanelAPI.framework"
/bin/rm -rf "/Library/Application Support/Blackmagic Design/DaVinci Resolve Panels"

##### ^^^^^ Borrowed code ends here ^^^^^ #####

echo "***End $SCRIPTNAME script***"
/bin/date

exit 0

