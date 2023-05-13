#!/bin/bash

##########################################################################
#   uninstall_hd_driver.command
#  
#   Shell script to uninstall the Avid HD Driver and Core Audio components.
#
#   You must be logged in as an administrator before running this script.
#   During the script execution, you will be prompted for an administrator
#   password.
#  
#   ©2019-2021 Avid Technology, Inc. All rights reserved. Portions copyright
#   PACE Anti-Piracy.
#
#	21.10b4: Remove installed items hidden in gUser/Library, UI formatting for clarity
#			 on 80 column windows, prompt instead of kill open apps
#	21.10b3: Add check and clear if a staged DigiDal.kext exists
#	21.10b2: Fixed AudioServiceHelper name, which now includes 'XPC'
#	21.10b1: Conditionalize when to unloadAgent, based on OS version range
#			 Add shutdown of Pro Tools, DigiTest or installer when uninstall
#
#	ITEMS NOT UNINSTALLED:	/Users/<username>/Library/Logs/Avid
#
##########################################################################

gToolVersion="21.10b4"

gAudioServiceHelperLabel="com.avid.AvidAudioServiceXPCHelper"
gAudioServiceHelperPlistPath="/Library/LaunchDaemons/$gAudioServiceHelperLabel.plist"
gAudioServiceTarget="system/$gAudioServiceHelperLabel"

gCoreAudioDaemonLabel="com.apple.audio.coreaudiod"
gCoreAudioDaemonPlistPath="/Library/LaunchDaemons/$gCoreAudioDaemonLabel.plist"
gAudioServerAgentPlistPath="/Library/LaunchAgents/com.avid.AvidAudioServer.plist"

gLaunchctlCommand="/usr/bin/sudo /bin/launchctl"
gDalDriver="/Library/Extensions/DigiDal.kext"
gStagedDalDriver="/Library/StagedExtensions/Library/Extensions/DigiDal.kext"
gYosemiteMajorVersion=14
gHighSierraMajorVersion=17
# Get the OS version (kernel version)
gOsVersion=`uname -r`
gOsMajorVersion=${gOsVersion%%.*}
gUser=`id -un`
gRebootNeeded="FALSE"
# Possible result codes from launchctl under Catalina or higher
gEINPROGRESS=36		# Operation now in progress result code
gEALREADY=37		# Operation already in progress

#-------------------------------------------------------------------------------
# Unload audio server agent via launchctl for all logged in users.

unloadAgent()
{
    echo "Unloading audio service helper agent..."

    # Check to see if the audio service helper agent plist file exists. If it doesn't then
    # There's nothing to unload
    if [[ ! -f "$gAudioServerAgentPlistPath" ]]; then
        echo "Could not find the audio service helper agent plist file. Nothing to unload."
    else
        # Unload the agent
        if [[ $gOsMajorVersion -ge $gYosemiteMajorVersion ]]; then   
            for pid_uid in $(ps -axo pid,uid,args | grep -i "[l]oginwindow.app" | awk '{print $1 "," $2}'); do
                pid=$(echo $pid_uid | cut -d, -f1)
                uid=$(echo $pid_uid | cut -d, -f2)
                echo "Unloading this plist for user $uid: $gAgentPlistPath"
                `$gLaunchctlCommand asuser "$uid" $gLaunchctlCommand unload $gAgentPlistPath`
            done
        else
            fatalError "launchctl asuser command not available on this OS version."
        fi
    fi
}

#-------------------------------------------------------------------------------
# If audio service helper is running, then stop it now.

unloadAudioServerHelperDaemon()
{
    echo "Unloading Audio Server daemon as needed..."

    # If an instance of the daemon is currently running, unload it using launchctl.
    # We may have to wait for it to be gone.
    `$gLaunchctlCommand list | /usr/bin/grep -q "$gAudioServiceHelperLabel"`
    if [[ $? -eq 0 ]]; then
        # Audio Server Helper is running so we need to unload it. If this is a new enough OS, then
        # use the launchctl 2.0 bootstrap commands. Otherwise fall back and use the legacy
        # launchctl commands.
        result=0
        waitForDaemonToQuit=0
        if [[ $gOsMajorVersion -ge $gLaunchctl2MajorVersion ]]; then
            # Use launchctl 2.0 bootout command on this system. If the plist exists, then
            # use the plist's path to do the remove. If it doesn't exist, use the service
            # target instead.
            if [[ -f "$gAudioServiceHelperPlistPath" ]]; then
                echo "Unbootstrapping the audio server helper daemon service from the system domain by plist..."
                `$gLaunchctlCommand bootout system "$gAudioServiceHelperPlistPath"`
                result=$?
				# Apple indicated that EINPROGRESS is a possible valid result code (as seen
				# on Catalina), so we handle it here. We also accept EALREADY because it
				# seems possible, even if we haven't seen it in the field yet.
				if [[ $result -ne 0 && $result -ne $gEINPROGRESS && $result -ne $gEALREADY ]]; then
					fatalError "launchctl bootout by plist failed with error $result"
                fi
            else
                # We have no plist so we have to remove by service target. Unfortunately
                # we've seen cases where launchctl returns immediately with an error even
                # though it did tell the service to quit. Therefore we ignore any errors
                # and remember that we need to wait for audio server helper to quit below.
                echo "Unbootstrapping the audio server helper daemon service from the system domain by service target..."
                `$gLaunchctlCommand bootout $gAudioServiceTarget`
                result=$?
                if [[ $result -ne 0 ]]; then
                    echo "launchctl bootout by service target returned error $result. This is considered non-fatal."
                    result=0
                fi

                # Remember that we need to wait for audio server helper to quit below.
                waitForDaemonToQuit=1
            fi    # The audio server helper plist file is missing
        else
            # If the plist file exists, use the unload command (which blocks until audio service helper daemon
            # is unloaded. If the plist file does not exist, and if the OS is Leopard or
            # above then use the remove command. But since remove returns immediately, we
            # have to remember to wait for audio server helper to stop.
            if [[ -f "$gAudioServiceHelperPlistPath" ]]; then
                echo "Unloading audio server helper from launchctl by plist..."
                `$gLaunchctlCommand unload "$gAudioServiceHelperPlistPath"`
                result=$?
                if [[ $result -ne 0 ]]; then
                    fatalError "launchctl unload failed with error $result"
                fi
            else
                # We have no plist so we have to remove audio service helper daemon by its label. We can only
                # do that on Leopard or above.
                if [[ $gOsMajorVersion -ge 9 ]]; then
                    echo "Removing audio service helper daemon from launchctl by label..."
                    `$gLaunchctlCommand remove "$gAudioServiceHelperLabel"`
                    result=$?

                    # Since "remove" returns immediately, remember that we want to wait for audio server helper
                    # to quit below.
                    waitForDaemonToQuit=1
                else
                    # This system is older than Leopard so we cannot remove the service by label.
                    # Since the plist is missing, this means we cannot unload audio server helper. Oh well.
                    fatalError "The audio service helper daemon plist is missing so we cannot unload it on this OS."
                fi
            fi    # The audio service helper daemon plist file is missing

            # Check the unload or remove result
            if [[ $result -ne 0 ]]; then
                fatalError "launchctl unload or remove failed with error $result"
            fi
        fi    # The OS too old for launchctl 2.0 syntax

        # Since some of the logic above results in calls to launchctl that return immediately,
        # double-check that the daemon was successfully removed if we were told to do so.
        #
        # To do this, we loop up to 60 times with a 1-second delay between checks. This
        # gives audio service helper daemon a full minute to quit.
        if [[ $waitForDaemonToQuit -ne 0 ]]; then
            daemonStopped=0
            daemonCheckCount=0
            for (( daemonCheckCount=0 ; $daemonCheckCount != 60 ; daemonCheckCount=daemonCheckCount+1 ))
            do
                `$gLaunchctlCommand list | /usr/bin/grep -q "$gAudioServiceHelperLabel"`
                if [[ $? -ne 0 ]]; then
                    daemonStopped=1
                    echo "The audio service helper daemon has stopped."
                    break
                fi

                echo "Waiting for the audio service helper daemon to stop..."
                sleep 1 # give it more time
            done

            # If we audio service helper was not stopped, report the error and fail
            if [[ $daemonStopped -eq 0 ]]; then
                fatalError "Audio service helper still found under launchctl control after $daemonCheckCount seconds."
            fi
        fi    # Double check that audio service helper daemon was unloaded.

        # audio service helper daemon was successfully unloaded
        echo "audio service helper daemon was successfully unloaded."
    else
        # audio service helper was not running
        echo "The audio service helper daemon is not running. Nothing to do."
    fi
	
    echo
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
            echo "Unable to delete $1."
#            exit 1
        fi
    fi
}

#-------------------------------------------------------------------------------
# If a folder exists at the specified path, and it is empty, then delete it.

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

quitRunningApplication()
{
	echo "This script cannot run while $1 is running."
	echo "Please quit $1 and re-run this script."
#	osascript -e 'delay 3' -e 'tell Application "$1"' -e 'quit' -e 'end tell'
	exit 0
}

#-------------------------------------------------------------------------------
fatalError()
{
    echo "Fatal Error: $1"
    exit 1
}



#-------------------------------------------------------------------------------
# Script starts here
#-------------------------------------------------------------------------------

if [ $gOsMajorVersion -lt 14 ]; then
    # OS is Mavericks or below
    echo "This script can only run on MacOS 10.10 or later."
    exit 1
fi

echo " "
echo "***********************************************************************************"
echo " "
echo "                          Avid HD Driver Uninstaller"
echo "                               Version $gToolVersion"
echo " "
echo "      This will uninstall the Avid HD Driver, Core Audio and DigiTest files."
echo " "
echo "***********************************************************************************"
echo " "
echo " "
echo "You must be logged in from an administrator account to uninstall the Avid HD Driver."

# Shutdown Pro Tools and DigiTest, if they are running:
#ps -axcopid,command | grep "Pro Tools" | awk '{ system("sudo kill -9 "$1) }'
#ps -axcopid,command | grep "DigiTest" | awk '{ system("sudo kill -9 "$1) }'
#ps -axcopid,command | grep "Installer" | awk '{ system("sudo kill -9 "$1) }'
pgrep -x "Pro Tools" >/dev/null && quitRunningApplication "Pro Tools"
pgrep -x "DigiTest" >/dev/null && quitRunningApplication "DigiTest"
pgrep -x "Installer" >/dev/null && quitRunningApplication "Installer"

# Unload the Mac system core audio before stopping Avid daemon: <-- legacy command
#sudo launchctl unload $gCoreAudioDaemonPlistPath

sudo launchctl disable system/com.avid.AvidAudioServiceHelper

unloadAudioServerHelperDaemon

# macOS 10.10-10.13 allowed launchtl unload on /Library/LaunchAgents/com.avid.AvidAudioServer.plist
if [[ $gOsMajorVersion -ge $gYosemiteMajorVersion ]]; then
    if [[ $gOsMajorVersion -lt $gHighSierraMajorVersion ]]; then
        echo "Unloading Audio Server Agent..."
        unloadAgent
    fi
else
	echo "Not unloading the Avid Audio Server agent because the OS is too old."
fi

echo "Removing Avid Audio Server files..."
deleteFileIfExist "/Applications/Avid/AvidAudioServer/AvidAudioServer.app"
deleteFileIfExist "/Applications/Avid/AvidAudioServer/AvidAudioServerLauncher.app"
deleteFileIfExist "/Applications/Avid/AvidAudioServer"
echo "Removing Avid DigiTest files..."
deleteFileIfExist "/Applications/Utilities/Avid DigiTest"
sudo rm -rf "/Applications/Utilities/Avid DigiTest"
deleteFileIfExist "/Users/$gUser/Library/Saved Application State/com.digidesign.DigiTest.savedState"
echo "Removing AvidLink HD Driver files..."
deleteFileIfExist "/Library/Application Support/Avid/CustomDataAppMan/HD Driver.xml"
echo "Removing AvidAudioPlugIn.driver..."
deleteFileIfExist "/Library/Audio/Plug-Ins/HAL/AvidAudioPlugIn.driver"
deleteFileIfExist "/Library/Audio/Plug-Ins/HAL/Avid CoreAudio.plugin" # old (PT 11.X-12.X)
if [[ -e "/Applications/Pro Tools.app" ]]; then
    echo "Pro Tools application found. Not removing /Applications/Avid/Licenses/Avid/Pro Tools/LICENSE.pdf"
else
	echo "Removing License file..."
	sudo rm -rf "/Applications/Avid/Licenses/Avid/Pro Tools/LICENSE.pdf"
	sudo rm -df "/Applications/Avid/Licenses/Avid/Pro Tools"	
	deleteFolderIfEmpty "/Applications/Avid/Licenses/Avid"
	deleteFolderIfEmpty "/Applications/Avid/Licenses"
	deleteFolderIfEmpty "/Applications/Avid"	
fi

# kextunload doesn't work unless you install Dal and then don't reboot. A restart after removing
# the Dal is required to unload it. If you are installing another HD Driver after using this
# uninstaller, then you won't need to reboot in between - just reboot at the end of the install.
echo "Search for and remove Dal kernel driver..."    
if [[ -e "$gDalDriver" ]]; then
    # sudo kextunload -b com.digidesign.iokit.DigiDal
    # sleep 5
    deleteFileIfExist "/Library/Extensions/DigiDal.kext"
    sudo rm -rf "/Library/Extensions/DigiDal.kext"
    echo "Touching kext cache..."
    sudo touch "/Library/Extensions"
    gRebootNeeded="TRUE"
else
    echo "The HD Driver extension is not present in /Library/Extensions/. Nothing to remove."
fi

if [[ -e "$gStagedDalDriver" ]]; then
	echo "Clear staged DigiDal.kext"
	sudo kmutil clear-staging
    sudo touch "/Library/Extensions"
    gRebootNeeded="TRUE"
fi
deleteFileIfExist "/Users/$gUser/Library/Preferences/Avid/AvidAudioServer"
deleteFileIfExist "/Library/PrivilegedHelperTools/AvidAudioServiceHelper.xpc"
deleteFileIfExist "/Library/LaunchAgents/com.avid.AvidAudioServer.plist"
deleteFileIfExist "/Library/LaunchDaemons/com.avid.AvidAudioServiceHelper.plist"

deleteFileIfExist "/Users/$gUser/Library/Preferences/Avid/AvidAudioServer"
deleteFileIfExist "/Users/$gUser/Library/Preferences/com.avid.AudioServer.plist"
deleteFileIfExist "/Users/$gUser/Library/Preferences/com.avid.CoreAudioManager.plist" # old (PT 11.X-12.X)

# Remove package receipts:
echo "Cleaning up installer receipts..."
sudo pkgutil --forget com.avid.installer.osx.HDFamilyDriver
sudo pkgutil --forget com.avid.installer.osx.HDFamilyDriverAppMan
deleteFileIfExist "/private/var/db/receipts/com.avid.installer.osx.AvidCoreAudio.bom" # old (PT 11.X-12.X)
deleteFileIfExist "/private/var/db/receipts/com.avid.installer.osx.AvidCoreAudio.plist" # old (PT 11.X-12.X)
deleteFileIfExist "/private/var/db/receipts/com.avid.installer.osx.HDFamilyDriver.bom" # old (PT 11.X-12.X)
deleteFileIfExist "/private/var/db/receipts/com.avid.installer.osx.HDFamilyDriver.plist" # old (PT 11.X-12.X)
deleteFileIfExist "/private/var/db/receipts/com.avid.installer.osx.HDFamilySignedDriver.bom" # old (PT 11.X-12.X)
deleteFileIfExist "/private/var/db/receipts/com.avid.installer.osx.HDFamilySignedDriver.plist" # old (PT 11.X-12.X)

if [[ "$gRebootNeeded" == "TRUE" ]]; then
    buttonVal=`osascript -e 'display dialog "A restart is required in order to complete the HD Driver uninstallation." buttons {"Restart Later", "Restart Now"} default button 2'`;

    if [[ $buttonVal = 'button returned:Restart Now' ]]; then
        echo " "
        echo "Avid HD Driver has been uninstalled successfully. Restarting..."
        sleep 2
        osascript -e 'tell application "System Events" to restart'
    else
        echo " "
        echo "** IMPORTANT **"
        echo " "
        echo "Avid HD Driver files have been removed successfully, but a restart is required to complete the uninstallation."
        `sudo -k` # Reset cached password
        sleep 10
    fi
else
    echo " "
    echo "Avid HD Driver files have been uninstalled successfully."
    `sudo -k` # Reset cached password
    sleep 10
fi

exit 0
