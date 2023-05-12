#!/bin/bash

##########################################################################
#   uninstall pro tools.command
#  
#   Shell script to uninstall Avid Pro Tools.
#
#   You must be logged in from an administrator account to run this script.
#   During the script execution, you will be prompted for an administrator
#   password.
#  
#   ©2019-2022 Avid Technology, Inc. All rights reserved.
#
#   22.4b1:  Disable prompt/uninstall of FB360 plug-in as it is no longer
#            included in the main PT installer, add prompt for uninstalling
#            core plug-ins with warning text about possible Media Composer breakage
#
#	21.10b3: Add files to Melodyne, FB360 cleanup list, add deleteFolderIfEmpty function,
#			 add prompts to delete Melodyne, FB360, and the PT Preferences,
#            prompt instead of kill open apps
#	21.10b2: Remove installed items hidden in gUser/Library, UI formatting
#	 		 for clarity on 80 column windows
#	21.10a1: Initial creation -cnow
#
#
#	ITEMS NOT UNINSTALLED:	/Users/<username>/Library/Logs/Avid
#							/Users/<username>/Documents/Pro Tools
##########################################################################

gToolVersion="22.9b1"

# Get the kernel (Darwin) version
gKernelVersion=$(uname -r)
gKernelMajorVersion=$(echo "$gKernelVersion" | cut -d. -f1)
gUser=`id -un`
gRebootNeeded="FALSE"
gRemoveSettings="FALSE"
gSettingsRemoved="FALSE"

#-------------------------------------------------------------------------------

removeProToolsAppFiles()
{
    echo
    echo "Removing Pro Tools files..."
    deleteFileIfExist "/Applications/Pro Tools.app"
    deleteFileIfExist "/Applications/Avid/Licenses/Avid/Pro Tools"
    deleteFileIfExist "/Applications/Avid/Licenses/Third Party"
#	deleteFileIfExist "/Library/Application Support/Avid/AVX2_Plug-ins"
    deleteFileIfExist "/Library/Application Support/Avid/Licenses"
    deleteFileIfExist "/Library/Application Support/Avid/Pro Tools"
    deleteFileIfExist "/Library/Application Support/Propellerhead Software" 
    deleteFileIfExist "/Applications/Utilities/ZipRecentLogs.command"
    deleteFileIfExist "/Library/Audio/MIDI Patch Names/Avid"
    deleteFileIfExist "/Library/Audio/MIDI Devices/Digidesign Device List.middev"
    deleteFileIfExist "/Library/Audio/MIDI Devices/Generic/Images/Digidesign_MIDI_IO.tiff"
    deleteFileIfExist "/Library/Audio/MIDI Devices/Generic/Images/Digidesign_PRE.tiff"
    deleteFileIfExist "/Library/LaunchDaemons/com.avid.bsd.shoetoolv120.plist"
    deleteFileIfExist "/Library/PrivilegedHelperTools/com.avid.bsd.shoetoolv120"
    deleteFileIfExist "/Users/Shared/AvidVideoEngine"
    deleteFileIfExist "/Users/Shared/Pro Tools"
    deleteFileIfExist "/Users/$gUser/Library/Application Support/Avid/Pro Tools"
    deleteFileIfExist "/Users/$gUser/Library/Application Support/Digidesign"
#   deleteFileIfExist "/Users/$gUser/Library/Preferences/Avid/Pro Tools" # Removed via prompt
    deleteFileIfExist "/Users/$gUser/Library/Saved Application State/com.avid.ProTools.savedState"
    echo "Removing Application Manager..."
    deleteFileIfExist "/Applications/Avid/Application Manager"
    deleteFileIfExist "/Library/Application Support/Avid/CustomDataAppMan/Pro Tools.xml"
          
    # Remove package receipts:
    echo "Cleaning up Pro Tools installer receipts..."
    sudo pkgutil --forget com.avid.installer.osx.ProToolsApplication
    sudo pkgutil --forget com.avid.installer.osx.ProToolsApplicationAppMan
}

#-------------------------------------------------------------------------------

removeCorePlugIns()
{
    echo
    echo "Removing PT Core Plug-Ins..."
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/AutoPan.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/BF-76.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/ChannelStrip.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/ClickII.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/DVerb.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/Dither.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/DownMixer.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/DynamicsIII.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/EQIII.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/Eleven Lite.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/InTune.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/Invert-Duplicate.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/LoFi.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/MasterMeter.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/Maxim.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/ModDelay_III.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/Normalize-Gain.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/Pitch Shift Legacy.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/PitchII.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/RectiFi.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/Reverse-DC Removal.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/SansAmp PSA-1.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/SciFi.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/SignalGenerator.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/Time Shift.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/TimeAdjuster.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/Trim.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/VariFi.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/AutoPan.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/BF-76.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/ChannelStrip.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/ClickII.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/DVerb.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/Dither.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/DownMixer.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/DynamicsIII.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/EQIII.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/Eleven Lite.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/InTune.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/Invert-Duplicate.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/LoFi.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/MasterMeter.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/Maxim.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/ModDelay_III.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/Normalize-Gain.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/Pitch Shift Legacy.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/PitchII.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/RectiFi.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/Reverse-DC Removal.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/SansAmp PSA-1.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/SciFi.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/SignalGenerator.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/Time Shift.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/TimeAdjuster.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/Trim.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/VariFi.aaxplugin"
}

#-------------------------------------------------------------------------------

removeMelodyne()
{
    deleteFileIfExist "/Library/Application Support/Celemony"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/Melodyne.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/Melodyne.aaxplugin"
    deleteFileIfExist "/Library/Audio/Plug-Ins/Components/Melodyne.component"
    deleteFileIfExist "/Library/Audio/Plug-Ins/VST3/Melodyne.vst3"
    deleteFileIfExist "/Users/Shared/Library/Application Support/Celemony"
    echo "Cleaning up Melodyne installer receipts..."
    sudo pkgutil --forget com.celemony.melodyne.aax
    sudo pkgutil --forget com.celemony.melodyne.au
    sudo pkgutil --forget com.celemony.melodyne.standalone
    sudo pkgutil --forget com.celemony.melodyne.vst3
    
    deleteFileIfExist "/Users/$gUser/Library/Application Support/Celemony"
    deleteFileIfExist "/Users/$gUser/Library/Preferences/com.celemony.melodyne.pref.plist"
}

#-------------------------------------------------------------------------------

removeFB360()
{
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/FB360-Control-ambiX.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/FB360-Converter-ambiX.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/FB360-Mix-Loudness-ambiX.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/FB360-Spatialiser-ambiX.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins/FB360-Stereo-Loudness-ambiX.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/FB360-Control-ambiX.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/FB360-Converter-ambiX.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/FB360-Mix-Loudness-ambiX.aaxplugin"
	deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/FB360-Spatialiser-ambiX.aaxplugin"
    deleteFileIfExist "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)/FB360-Stereo-Loudness-ambiX.aaxplugin"
    deleteFileIfExist "/Applications/FB360 Spatial Workstation"
    deleteFileIfExist "/Users/Shared/FB360 Spatial Workstation"
    echo "Cleaning up fb360 installer receipts..."
    sudo pkgutil --forget com.fb.audio360.UI
    sudo pkgutil --forget com.fb.audio360.aax
    sudo pkgutil --forget com.fb.audio360.doc
    sudo pkgutil --forget com.fb.audio360.pttemplate
    sudo pkgutil --forget com.fb.audio360.shell    
    deleteFileIfExist "/Users/$gUser/Library/Application Support/FB360 Spatial Workstation"
}

#-------------------------------------------------------------------------------

cleanupFolders()
{
	deleteFolderIfEmpty "/Library/Application Support/Avid/CustomDataAppMan"
    deleteFolderIfEmpty "/Library/Application Support/Avid/Audio/Plug-Ins"
    deleteFolderIfEmpty "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)"
    deleteFolderIfEmpty "/Library/Application Support/Avid/Audio"     
    deleteFolderIfEmpty "/Library/Application Support/Avid"
    deleteFolderIfEmpty "/Applications/Avid/Licenses/Avid"
    deleteFolderIfEmpty "/Applications/Avid/Licenses"
	deleteFolderIfEmpty "/Applications/Avid"
}

#-------------------------------------------------------------------------------

removeDockIcon() # Requires PListBuddy utility
{
	#delete item from com.apple.dock.plist
	dloc=$(defaults read com.apple.dock persistent-apps | grep file-label | awk '/Pro Tools/  {printf NR}')
	dloc=$[$dloc-1]
	echo $dloc
	sudo -u $USER /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist

	#must delete item from com.apple.dock.plist agian,or won't change
	dloc=$(defaults read com.apple.dock persistent-apps | grep file-label | awk '/Pro Tools/  {printf NR}')
	#dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString "PageManager%209.31.app")
	dloc=$[$dloc-1]
	echo $dloc
	sudo -u $USER /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist
	sleep 3
	# Restart Dock to persist changes
	osascript -e 'delay 3' -e 'tell Application "Dock"' -e 'quit' -e 'end tell'
}

#-------------------------------------------------------------------------------

removeSettings()
{
	echo
	echo "Choosing yes will completely remove Pro Tools settings, and session templates!"
	promptUser 
	if [[ $? -eq 0 ]]; then 
		deleteFileIfExist "/Users/$gUser/Documents/Pro Tools"
		return 0
	else
		echo "Pro Tools settings will NOT be removed."
		return 1
	fi
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
        sudo /bin/rm -rf "$1"
        if [[ $? -ne 0 ]]; then
            echo "Unable to remove $1."
#            exit 1
        fi
    fi
}

#-------------------------------------------------------------------------------

deleteFolderIfEmpty()
{
    if [[ ( -e "$1" ) && ( -d "$1" ) ]]; then
    	if [[ -e "$1/.DS_Store" ]]; then
    		sudo /bin/rm -f "$1/.DS_Store"
    	fi
		if [[ "$(ls -A "$1")" ]]; then
			echo "$1 contains files from other product installations. It will not be removed"
		else
        	# Remove the file:
        	sudo chflags -R nouchg "$1"
        	echo "Removing $1."
        	sudo /bin/rm -df "$1"
        	if [[ $? -ne 0 ]]; then
            	echo "Unable to remove $1."
        	fi
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
	echo
	if [[ "$gSettingsRemoved" == "TRUE" ]]; then	
    	echo "********************************************************************************"
    	echo "*     Avid Pro Tools files have been uninstalled successfully." 
    	echo "*"
    	echo "*     To complete a 'Clean' uninstallation:" 
    	echo "*"
    	echo "*        - Manually remove PT Dock icons (macOS 10.15 and earlier)"
    	echo "*        - Uninstall the support products that were installed with Pro Tools."
    	echo "*"
    	echo "*     To uninstall Avid Link, Avid Cloud Client Services or Avid HD Driver," 
   		echo "*     please go to /Applications/Avid_Uninstallers and run their respective"
    	echo "*     uninstallers."
    	echo "*"   
    	echo "********************************************************************************"
	else
    	echo "********************************************************************************"
    	echo "*     Avid Pro Tools files have been uninstalled successfully." 
    	echo "*"
    	echo "*     To complete a 'Clean' uninstallation:" 
    	echo "*"  
    	echo "*        - Manually remove PT Dock icons (macOS 10.15 and earlier)"
    	echo "*        - Manually remove the /Users/$gUser/Documents/Pro Tools folder, BUT"
    	echo "*          note that it may contain important saved settings."
    	echo "*          Remember to backup your settings before deleting this folder."
    	echo "*        - Uninstall the support products that were installed with Pro Tools."	
		echo "*"
    	echo "*     To uninstall Avid Link, Avid Cloud Client Services or Avid HD Driver," 
   		echo "*     please go to /Applications/Avid_Uninstallers and run their respective"
    	echo "*     uninstallers."
    	echo "*"   
    	echo "********************************************************************************"
    fi
}

#-------------------------------------------------------------------------------

quitRunningApplication()
{
	echo "This script cannot run while $1 is running."
	echo "Please quit $1 and re-run this script."
#	osascript -e 'delay 3' -e 'tell Application "$1"' -e 'quit' -e 'end tell'
	exit 0
}


#-------------------------------------------------------------------------------
# Script starts here
#-------------------------------------------------------------------------------

if [[ $gKernelMajorVersion -lt 18 ]]; then
    # OS is High Sierra 10.13 (kernel 17.X) or below. Mojave 10.14 is kernel v18.X
    echo "This script can only run on macOS 10.14 or later."
    exit 1
fi

# Remove Pro Tools settings if "nuke" flag used with script:
if [[ ( "$1" ) && ( "$1" == "-nuke" ) ]]; then
	gRemoveSettings="TRUE"
	echo "$gRemoveSettings"
fi

echo
echo "********************************************************************************"
echo
echo "                         Avid Pro Tools Uninstaller"
echo "                              Version $gToolVersion"
echo
echo "PLEASE NOTE: This will remove Pro Tools, core plug-ins and associated files that"
echo "were installed OUTSIDE of /Users/$gUser/Documents/Pro Tools."
echo
echo "You will be prompted to uninstall Melodyne Plug-Ins, Pro Tools Core Plug-Ins and"
echo "Pro Tools softare/hardware preferences"
echo
echo "Settings, sessions and template files in /Users/$gUser/Documents/Pro Tools" 
echo "WILL NOT be removed."
echo "********************************************************************************"
echo
echo
echo "You must be logged in from an administrator account to uninstall Avid Pro Tools."

# Shutdown Pro Tools and DigiTest, if they are running:
pgrep -x "Pro Tools" >/dev/null && quitRunningApplication "Pro Tools"
pgrep -x "DigiTest" >/dev/null && quitRunningApplication "DigiTest"
pgrep -x "Installer" >/dev/null && quitRunningApplication "Installer"
#ps -axcopid,command | grep "Pro Tools" | awk '{ system("sudo kill -9 "$1) }'
#ps -axcopid,command | grep "DigiTest" | awk '{ system("sudo kill -9 "$1) }'
#ps -axcopid,command | grep "Installer" | awk '{ system("sudo kill -9 "$1) }'

# Remove Pro Tools files/Core Plug-Ins:
removeProToolsAppFiles

# Remove PT Core Plug-Ins:
echo
echo
echo "*********************** ATTENTION MEDIA COMPOSER USERS ***********************"
echo "Removing Pro Tools Core Plug-Ins will break audio processing in Media Composer."
echo "If you are using Avid Media Composer, type NO in response to the next prompt."
echo
promptUser "Do you want to remove the Pro Tools Core plug-ins"
if [[ $? -eq 0 ]]; then removeCorePlugIns; fi

# Remove Melodyne Plug-In:
promptUser "Do you want to remove the Melodyne Celemony plug-in"
if [[ $? -eq 0 ]]; then removeMelodyne; fi

# Remove Pro Tools Preferences:
promptUser "Do you want to remove the Pro Tools software/hardware preferences"
if [[ $? -eq 0 ]]; then deleteFileIfExist "/Users/$gUser/Library/Preferences/Avid/Pro Tools"; fi

# Remove Pro Tools settings/templates:
if [[ "$gRemoveSettings" == "TRUE" ]]; then 
	promptUser "Do you want to remove the Pro Tools settings and templates"
	if [[ $? -eq 0 ]]; then removeSettings; gSettingsRemoved="TRUE"; fi
fi

# Delete any empty folders leftover from the installation/uninstallation:
cleanupFolders

if [[ "$gRebootNeeded" == "TRUE" ]]; then
    buttonVal=`osascript -e 'display dialog "A restart is required in order to complete the Pro Tools uninstallation." buttons {"Restart Later", "Restart Now"} default button 2'`;

    if [[ $buttonVal = 'button returned:Restart Now' ]]; then
        echo 
        echo "Avid Pro Tools has been uninstalled successfully. Restarting..."
        sleep 2
        osascript -e 'tell application "System Events" to restart'
    else
        echo 
        echo "** IMPORTANT **"
        echo 
        echo "Avid Pro Tools files have been removed successfully, but a restart is required to complete the uninstallation."
        sudo -k # Reset cached password
        sleep 10
    fi
else
    showFinalInformation
fi

sudo -k # Reset cached password
exit 0
