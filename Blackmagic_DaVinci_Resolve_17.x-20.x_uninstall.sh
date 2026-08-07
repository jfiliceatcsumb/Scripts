#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Uninstall script for Blackmagic DaVinci Resolve (Studio) 17.x-21.x.
# Using code in script from Resolve uninstall application.
# /Volumes/Blackmagic DaVinci Resolve/Uninstall Resolve.app/Contents/Resources/uninstall.sh
# 
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

# Test whether Resolve is already installed. Exit if not found.

 if [ ! -e "$mountPoint/Applications/DaVinci Resolve/" ] 
 then
 	echo "/Applications/DaVinci Resolve not found on system, so exiting script..."
 	exit 0
 fi
 

##### vvvvv Borrowed code starts here vvvvv #####
unload_panel_daemon()
{
    local agentsfolder="/Library/LaunchAgents"
    local type="com.blackmagic-design.DaVinciResolveBMDPanelDaemon"

    # find the current user who is logged in and try to stop the panel daemon as that user
    local USER_NAME=`stat -f '%Su' /dev/console`
    su - "$USER_NAME" -c "launchctl remove $type" 2> /dev/null

    if [ -f "$agentsfolder/$type.plist" ]
    then
        launchctl unload "$agentsfolder/$type.plist" 2> /dev/null
        launchctl remove "$type" 2> /dev/null
        launchctl bootout system "$agentsfolder/$type.plist" 2> /dev/null
        sleep 1 # wait before deleting plist file that is being unload'ed, due to launchctl async behavior
        rm -f "$agentsfolder/$type.plist" 2> /dev/null
    fi

    rm -f "/var/tmp/davinci_socket"
}

# unconfigure BMD panel daemon
unload_panel_daemon

# unconfigure panel
if [[ -e "/Library/Application Support/Blackmagic Design/DaVinci Resolve/configure-panel.sh" ]]; then
	"/Library/Application Support/Blackmagic Design/DaVinci Resolve/configure-panel.sh" none
fi

# unconfigure dp
if [[ -e "/Library/Application Support/Blackmagic Design/DaVinci Resolve/configure-dp.sh" ]]; then
	"/Library/Application Support/Blackmagic Design/DaVinci Resolve/configure-dp.sh" off
fi

/bin/rm -rf "/Library/Application Support/Blackmagic Design/DaVinci Resolve/" &2>/dev/null
/bin/rm -rf "/Library/Preferences/Blackmagic Design/DaVinci Resolve/" &2>/dev/null


# Proxy Generator
if [ -e "/Applications/DaVinci Resolve/DaVinci Resolve.app/Contents/Applications/Blackmagic Proxy Generator" ]
then
    /bin/rm -rf "/Applications/Blackmagic Proxy Generator.app"
else
    if [ -e "/Applications/Blackmagic Proxy Generator Lite.app/Contents/Info.plist" ]
    then
        # Check to make sure the app bundle is NOT a standalone build
        \grep ">com.blackmagic-design.BlackmagicProxyGeneratorLite<" "/Applications/Blackmagic Proxy Generator Lite.app/Contents/Info.plist" > /dev/null
        if [ $? -eq 0 ]
        then
            /bin/rm -rf "/Applications/Blackmagic Proxy Generator Lite.app"
        fi
    fi
fi

# Application
/bin/rm -rf "/Applications/DaVinci Resolve/"

# Panels
/bin/rm -rf "/Library/Application Support/Blackmagic Design/DaVinci Resolve Advanced Panel" &2>/dev/null
/bin/rm -rf "/Library/Frameworks/DaVinciPanelAPI.framework" &2>/dev/null
/bin/rm -rf "/Library/Application Support/Blackmagic Design/DaVinci Resolve Panels/AdminUtility" &2>/dev/null
/bin/rmdir "/Library/Application Support/Blackmagic Design/DaVinci Resolve Panels" &2>/dev/null

# Fairlight Panels
/bin/rm -rf "/Library/Frameworks/FairlightPanelAPI.framework" &2>/dev/null

# Resolve Plugin
/bin/rm -rf "/Library/OFX/Plugins/DaVinci Resolve Renderer.ofx.bundle" &2>/dev/null

# Remove DDM packages: Re-consider what to do when multiple apps start using it
#/bin/rm -rf "/Library/Application Support/Blackmagic Design/DaVinci Resolve/Extras/" &2>/dev/null

##### ^^^^^ Borrowed code ends here ^^^^^ #####


exit 0
