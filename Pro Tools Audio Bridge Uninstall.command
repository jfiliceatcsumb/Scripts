#!/bin/bash

##########################################################################
#   Uninstall Pro Tools Audio Bridge.command
#
#   Shell script to uninstall Pro Tools Audio Bridge.
#
#    22.8b1: Initial creation. 7/30/2022 -cnow
#
##########################################################################

gToolVersion="22.8b3"

# Get the kernel (Darwin) version
gKernelVersion=$(uname -r)
gKernelMajorVersion=$(echo "$gKernelVersion" | cut -d. -f1)

gDriver="/Library/Audio/Plug-Ins/HAL/ProToolsAudioBridge.driver"
gOldDriver="/Library/Audio/Plug-Ins/HAL/AvidAudioBridge.driver"

#-------------------------------------------------------------------------------

removeProToolsAudioBridgeFiles()
{
    echo
    echo "Removing Pro Tools Audio Bridge..."

    deleteFileIfExist "$gOldDriver"
    deleteFileIfExist "$gDriver"
    deleteFileIfExist "Applications/Avid_Uninstallers/Uninstall Pro Tools Audio Bridge.command"

    # Remove package receipts:
    echo "Cleaning up Pro Tools installer receipts..."
    sudo pkgutil --forget com.avid.installer.osx.audio.bridge
    #sudo pkgutil --forget com.avid.installer.osx.audio.bridge.AppMan

    sudo launchctl kickstart -kp system/com.apple.audio.coreaudiod
}

#-------------------------------------------------------------------------------
# If a file or folder exists at the specified path, then delete it, and its entire
# contents if it's a directory.

deleteFileIfExist()
{
    if [[ -e "$1" ]]; then
        # If it's a directory, then make sure it doesn't contain any locked files:
        if [[ -d "$1" ]]; then
            sudo chflags -R nouchg "$1"
        fi

        # Remove the file:
        echo "Removing $1."
        sudo /bin/rm -drf "$1"
        if [[ $? -ne 0 ]]; then
            echo "Unable to remove $1."
#           exit 1
        fi
    fi
}

#-------------------------------------------------------------------------------

promptUser()
{
    local prompt response

    if [ "$1" ]; then prompt="$1";
        else prompt="Are you sure";
    fi

    prompt="$prompt [y/n] ?"
    echo
    while true; do
        read -r -p "$prompt " response
        case "$response" in
        [Yy][Ee][Ss]|[Yy]) # Yes, yes, Y or y
            return 0
        ;;
        [Nn][Oo]|[Nn])  # No, no, N or n
            return 1
        ;;
            *) # Loop on non-Y/N response
        ;;
        esac
    done
}

#-------------------------------------------------------------------------------

fatalError()
{
    echo "Fatal Error: $1"
    sudo -k # Reset cached password
    exit 1
}

#-------------------------------------------------------------------------------

showFinalInformation()
{
    echo "********************************************************************************"
    echo "      Pro Tools Audio Bridge has been uninstalled.                              "
    echo "********************************************************************************"
}

#-------------------------------------------------------------------------------

quitRunningApplication()
{
    echo "This script cannot run while $1 is running."
    echo "Please quit $1 and re-run this script."
#    osascript -e 'delay 3' -e 'tell Application "$1"' -e 'quit' -e 'end tell'
    exit 0
}

#-------------------------------------------------------------------------------
# Script starts here
#-------------------------------------------------------------------------------

if [[ $gKernelMajorVersion -lt 18 ]]; then
    # OS is High Sierra (10.13) or below. Mojave is kernel v18.X
    echo "This script can only run on macOS 10.14 or later."
    exit 1
fi

echo
echo "********************************************************************************"
echo
echo "                     Pro Tools Audio Bridge Uninstaller"
echo "                              Version $gToolVersion"
echo
echo "                               IMPORTANT!"
echo "YOU MUST QUIT ANY RUNNING AUDIO APPLICATIONS BEFORE CONTINUING THIS UNINSTALLER"
echo
echo "********************************************************************************"
echo
echo
echo "You must be logged in from an administrator account to uninstall"
echo "Pro Tools Audio Bridge."

# Shutdown Pro Tools and DigiTest, if they are running:
#pgrep -x "Pro Tools" >/dev/null && quitRunningApplication "Pro Tools"
#pgrep -x "DigiTest" >/dev/null && quitRunningApplication "DigiTest"
#pgrep -x "Installer" >/dev/null && quitRunningApplication "Installer"
#ps -axcopid,command | grep "Pro Tools" | awk '{ system("sudo kill -9 "$1) }'
#ps -axcopid,command | grep "DigiTest" | awk '{ system("sudo kill -9 "$1) }'
#ps -axcopid,command | grep "Installer" | awk '{ system("sudo kill -9 "$1) }'

# Remove Pro Tools Audio Bridge:
removeProToolsAudioBridgeFiles
showFinalInformation

sudo -k # Reset cached password
exit 0

