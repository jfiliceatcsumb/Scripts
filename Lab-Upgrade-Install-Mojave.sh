#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script requires .
# Run it with no arguments. 
# 
# Use as script in Jamf JSS.


# Change History:
# 2021/MM/DD:	Creation.
#

SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

# Jamf JSS Parameters 1 through 3 are predefined as mount point, computer name, and username

pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3


echo pathToScript=$pathToScript
echo mountPoint=$mountPoint
echo computerName=$computerName
echo userName=$userName

# set alias for PlistBuddy and several others so I don't have to specify full path.
# Prefix sudo path because I'm using it here for all commands.
# If I want to run a command without the alias, then specify the full path.
alias PlistBuddy="/usr/libexec/PlistBuddy"
alias chown="/usr/sbin/chown"
alias chmod="/bin/chmod"
alias ditto="/usr/bin/ditto"
alias defaults="/usr/bin/defaults"
alias rm="/bin/rm"
alias cp="/bin/cp"
alias mkdir="/bin/mkdir"
alias sudo=/usr/bin/sudo



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# USER VARIABLES
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

## Specify path to OS installer – Use Parameter 4 in the JSS, or specify here.
## Parameter Label: Path to the macOS installer
## Example: /Applications/Install macOS High Sierra.app
OSInstaller="$( echo "$4" | /usr/bin/xargs )"

## Version of Installer OS. Use Parameter 5 in the JSS, or specify here.
## Parameter Label: Version of macOS
## Example Command: /usr/libexec/PlistBuddy -c 'Print :"System Image Info":version' "/Applications/Install macOS High Sierra.app/Contents/SharedSupport/InstallInfo.plist"
## Example: 10.12.5
installerVersion="$5"
installerVersion_Full_Integer="$( /bin/echo "$installerVersion" | /usr/bin/awk -F. '{ print ($1 * 10 ** 4 + $2 * 10 ** 2 + $3 )}' )"
installerVersion_Major_Integer=$(/bin/echo "$installerVersion" | /usr/bin/cut -d. -f 1,2 | /usr/bin/awk -F. '{for(i=1; i<=NF; i++) {printf("%02d",$i)}}')

/bin/echo "installerVersion $installerVersion"
/bin/echo "installerVersion_Full_Integer $installerVersion_Full_Integer"
/bin/echo "installerVersion_Major_Integer $installerVersion_Major_Integer"

if [ "$installerVersion_Full_Integer" -lt 110000 ]; then
    installerDMG="${OSInstaller}/Contents/SharedSupport/InstallESD.dmg"
    installerPlist="${OSInstaller}/Contents/SharedSupport/InstallInfo.plist"
else
    installerDMG="${OSInstaller}/Contents/SharedSupport/SharedSupport.dmg"
    installerPlist="${OSInstaller}/Contents/Info.plist"
fi

## Custom Trigger used for download – Use Parameter 6 in the JSS, or specify here.
## Parameter Label: Download Policy Trigger
## This should match a custom trigger for a policy that contains just the
## MacOS installer. Make sure that the policy is scoped properly
## to relevant computers and/or users, or else the custom trigger will
## not be picked up. Use a separate policy for the script itself.
## Example trigger name: download-sierra-install
download_trigger="$( echo "$6" | /usr/bin/xargs )"

## MD5 Checksum of Installer dmg file – Use Parameter 7 in the JSS.
## Parameter Label: installESD Checksum (optional)
## This variable is OPTIONAL
## Leave the variable BLANK if you do NOT want to verify the checksum (DEFAULT)
## Example Command: /sbin/md5 /Applications/Install\ macOS\ High\ Sierra.app/Contents/SharedSupport/InstallESD.dmg
## Example MD5 Checksum: b15b9db3a90f9ae8a9df0f81741efa2b
installerDMGChecksum="$( echo "$7" | /usr/bin/xargs )"
if [ -n "$installerDMGChecksum" ]; then
    doCheckDMGchecksum=yes
else
    doCheckDMGchecksum=no
fi

## Erase & Install macOS (Factory Defaults)
## Requires macOS Installer 10.13.4 or later
## Disabled by default
## Options: 0 = Disabled / 1 = Enabled
## Use Parameter 8 in the JSS.
## Parameter Label: Upgrade or Erase (0 or 1)
eraseInstall="$8"
if [ "$eraseInstall" != "1" ]; then eraseInstall=0 ; fi
# macOS Installer 10.13.3 or ealier set 0 to it.
if [ "$installerVersion_Full_Integer" -lt 101304 ]; then
    eraseInstall=0
fi

## Enter 0 for Full Screen, 1 for Utility window (screenshots available on GitHub)
## Full Screen by default
## Use Parameter 9 in the JSS.
## Parameter Label: Full Screen or Dialog Box (0 or 1)
userDialog="$9"
if [ "$userDialog" != "1" ]; then userDialog=0 ; fi

## Enter yes to open /var/log/startosinstall.log
## Use Parameter 10 in the JSS.
## Parameter Label: Show Log File (yes or no)
ShowLogFile=$( /bin/echo "${10}" | /usr/bin/tr "[:upper:]" "[:lower:]" | /usr/bin/xargs)
if [ "$ShowLogFile" != "yes" ]; then ShowLogFile="no" ; fi

# Control for auth reboot execution.
if [ "$installerVersion_Major_Integer" -ge 1014 ]; then
    # Installer of macOS 10.14 or later set cancel to auth reboot.
    cancelFVAuthReboot=1
else
    # Installer of macOS 10.13 or earlier try to do auth reboot.
    cancelFVAuthReboot=0
fi


## Title of OS
macOSname=$(/bin/echo "$OSInstaller" | /usr/bin/sed -E 's/(.+)?Install(.+)\.app\/?/\2/' | /usr/bin/xargs)

## Title to be used for userDialog (only applies to Utility Window)
title="$macOSname Upgrade"

if [ "$eraseInstall" -eq 1 ]; then
	title="$macOSname Erase & Install"
fi

## Heading to be used for userDialog
heading="Please wait as we prepare your computer for $macOSname..."

## Description to be used for userDialog
description="Your computer should reboot in 5-10 minutes and begin the upgrade.
This process should normally take up to an hour to complete, 
(but could take up to 2 hours on slow Macs) during which it will restart several times. 
You will not be able to use the Mac while the upgrade is taking place."

if [ "$eraseInstall" -eq 1 ]; 
then
description="Your computer should reboot in 5-10 minutes and begin the erase and install.
This process should normally take up to an hour to complete, 
(but could take up to 2 hours on slow Macs) during which it will restart several times. 
You will not be able to use the Mac while the upgrade is taking place."
fi


## Description to be used prior to downloading the OS installer
dldescription="We need to download $macOSname to your computer; this will \
take several minutes."

## Jamf Helper HUD Position if macOS Installer needs to be downloaded
## Options: ul (Upper Left); ll (Lower Left); ur (Upper Right); lr (Lower Right)
## Leave this variable empty for HUD to be centered on main screen
dlPosition="ul"

## Icon to be used for userDialog
## Default is macOS Installer logo which is included in the staged installer package
icon="$OSInstaller/Contents/Resources/InstallAssistant.icns"

## First run script to remove the installers after run installer
finishOSInstallScriptFilePath="/usr/local/jamfps/finishOSInstall.sh"

## Launch deamon settings for first run script to remove the installers after run installer
osinstallersetupdDaemonSettingsFilePath="/Library/LaunchDaemons/com.jamfps.cleanupOSInstall.plist"

## Launch agent settings for filevault authenticated reboots
osinstallersetupdAgentSettingsFilePath="/Library/LaunchAgents/com.apple.install.osinstallersetupd.plist"

## Amount of time (in seconds) to allow a user to connect to AC power before moving on
## If null or 0, then the user will not have the opportunity to connect to AC power
acPowerWaitTimer="0"

## Declare the sysRequirementErrors array
declare -a sysRequirementErrors=()

## Icon to display during the AC Power warning
warnIcon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertCautionIcon.icns"

## Icon to display when errors are found
errorIcon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns"

## The startossinstall log file path
osinstallLogfile="/var/log/startosinstall.log"

## caffeinatePID
caffeinatePID=""

## The startossinstall command option array
declare -a startosinstallOptions=()

## Determine binary name
if [ "$installerVersion_Major_Integer" -ge 1011 ]; then
 binaryNameForOSInstallerSetup="osinstallersetupd"
else
 binaryNameForOSInstallerSetup="osinstallersetupplaind"
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# FUNCTIONS
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

kill_process() {
    processPID="$1"
    if /bin/ps -p "$processPID" > /dev/null ; then
        /bin/kill "$processPID"
        wait "$processPID" 2>/dev/null
    fi
}

wait_for_ac_power() {
    local jamfHelperPowerPID
    jamfHelperPowerPID="$1"
    ## Loop for "acPowerWaitTimer" seconds until either AC Power is detected or the timer is up
    /bin/echo "Waiting for AC power..."
    while [[ "$acPowerWaitTimer" -gt "0" ]]; do
        if /usr/bin/pmset -g ps | /usr/bin/grep "AC Power" > /dev/null ; then
            /bin/echo "Power Check: OK - AC Power Detected"
            kill_process "$jamfHelperPowerPID"
            return
        fi
        sleep 1
        ((acPowerWaitTimer--))
    done
    kill_process "$jamfHelperPowerPID"
    sysRequirementErrors+=("Is connected to AC power")
    /bin/echo "Power Check: ERROR - No AC Power Detected"
}

downloadInstaller() {
    if [ ! -x /usr/local/jamf/bin/jamf ]; then
        echo "Not found: /usr/local/jamf/bin/jamf"
        return
    fi

    /bin/rm -rf "${OSInstaller:-/tmp/dummy.$$}"

    /bin/echo "Downloading macOS Installer..."
    /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper \
        -windowType hud \
        -windowPosition $dlPosition \
        -title "$title" \
        -alignHeading center \
        -alignDescription left \
        -description "$dldescription" \
        -lockHUD \
        -icon "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarDownloadsFolder.icns" \
        -iconSize 100 &

    ## Capture PID for Jamf Helper HUD
    jamfHUDPID=$!

    ## Run policy to cache installer
    if /usr/local/jamf/bin/jamf policy -event "$download_trigger" ; then
        jamfPolicyResult=ok
    else
        jamfPolicyResult=ng
    fi

    ## Kill Jamf Helper HUD post download
    kill_process "$jamfHUDPID"

    if [ "$jamfPolicyResult" = "ng" ]; then
        /bin/echo "Abort due to failed jamf policy -event $download_trigger"
        cleanExit 1
    fi
}

validate_power_status() {
    ## Check if device is on battery or ac power
    ## If not, and our acPowerWaitTimer is above 1, allow user to connect to power for specified time period
    if /usr/bin/pmset -g ps | /usr/bin/grep "AC Power" > /dev/null ; then
        /bin/echo "Power Check: OK - AC Power Detected"
    else
        if [[ "$acPowerWaitTimer" -gt 0 ]]; then
            /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper \
                -windowType utility \
                -title "Waiting for AC Power Connection" \
                -icon "$warnIcon" \
                -description "Please connect your computer to power using an AC power adapter. This process will continue once AC power is detected." &
            wait_for_ac_power "$!"
        else
            sysRequirementErrors+=("Is connected to AC power")
            /bin/echo "Power Check: ERROR - No AC Power Detected"
        fi
    fi
}

validate_free_space() {
    local installerVersion diskInfoPlist freeSpace requiredDiskSpaceSizeGB installerPath installerSizeBytes

    installerVersion="$1"
    installerPath="$2"

    diskInfoPlist=$(/usr/sbin/diskutil info -plist /)
    ## 10.13.4 or later, diskutil info command output changes key from 'AvailableSpace' to 'Free Space' about disk space.
    ## 10.15.0 or later, diskutil info command output changes key from 'APFSContainerFree' to 'Free Space' about disk space.
    freeSpace=$(
    /usr/libexec/PlistBuddy -c "Print :APFSContainerFree" /dev/stdin <<< "$diskInfoPlist" 2>/dev/null || /usr/libexec/PlistBuddy -c "Print :FreeSpace" /dev/stdin <<< "$diskInfoPlist" 2>/dev/null || /usr/libexec/PlistBuddy -c "Print :AvailableSpace" /dev/stdin <<< "$diskInfoPlist" 2>/dev/null
    )

    ## The free space calculation also includes the installer, so it is excluded.
    if [ -e "$installerPath" ]; then
        installerSizeBytes=$(/usr/bin/du -s "$installerPath" | /usr/bin/awk '{print $1}' | /usr/bin/xargs)
        freeSpace=$((freeSpace + installerSizeBytes))
    fi

    ## Check if free space > 20GB (install 10.12+) or 48GB (install 11.00)
    requiredDiskSpaceSizeGB=$([ "$installerVersion_Major_Integer" -ge 1100 ] && /bin/echo "48" || /bin/echo "20")   	
    if [[ ${freeSpace%.*} -ge $(( requiredDiskSpaceSizeGB * 1000 ** 3 )) ]]; then
        /bin/echo "Disk Check: OK - ${freeSpace%.*} Bytes Free Space Detected"
    else
        sysRequirementErrors+=("Has at least ${requiredDiskSpaceSizeGB}GB of Free Space")
        /bin/echo "Disk Check: ERROR - ${freeSpace%.*} Bytes Free Space Detected"
    fi
}

verifyChecksum() {
    osChecksum=$( /sbin/md5 -q "$installerDMG" )
    if [ "$osChecksum" = "$installerDMGChecksum" ]; then
        /bin/echo "Valid"
    else
        /bin/echo "not Valid"
    fi
}

cleanExit() {
    if [ -n "$caffeinatePID" ]; then
      kill_process "$caffeinatePID"
    fi
    ## Remove Script
    /bin/rm -f "$finishOSInstallScriptFilePath"
    /bin/rm -f "$osinstallersetupdDaemonSettingsFilePath"
    /bin/rm -f "$osinstallersetupdAgentSettingsFilePath"
    exit "$1"
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# SYSTEM CHECKS
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

## If previous processes remain for some reason, the installation will freeze, so kill it.
killingProcesses=("caffeinate" "startosinstall" "$binaryNameForOSInstallerSetup")
for processName in "${killingProcesses[@]}"; do
    [ -z "$processName" ] && continue
    /bin/echo "Killing $processName processes."
    /usr/bin/killall "$processName" 2>&1 || true
done

## Caffeinate
/usr/bin/caffeinate -dis &
caffeinatePID=$!

##Get Current User
currentUser=$(/bin/echo 'show State:/Users/ConsoleUser' | /usr/sbin/scutil | /usr/bin/awk '/Name / { print $3 }')

## Check if FileVault Enabled
fvStatus=$( /usr/bin/fdesetup status | /usr/bin/head -1 )

## Run system requirement checks
validate_power_status
validate_free_space "$installerVersion_Major_Integer" "$OSInstaller"

## Don't waste the users time, exit here if system requirements are not met
if [[ "${#sysRequirementErrors[@]}" -ge 1 ]]; then
    /bin/echo "Launching jamfHelper Dialog (Requirements Not Met)..."
    /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper \
        -windowType utility \
        -title "$title" -icon "$errorIcon" \
        -iconSize 100 -button1 "OK" -defaultButton 1 \
        -heading "Requirements Not Met" \
        -description "We were unable to prepare your computer for $macOSname. Please ensure your computer meets the following requirements:

$( /usr/bin/printf '\t• %s\n' "${sysRequirementErrors[@]}" )

If you continue to experience this issue, please contact the IT Help Desk."
    cleanExit 1
fi

## Check for existing OS installer
loopCount=0
unsuccessfulDownload=1
maxTrialCount=3

while [ "$loopCount" -lt "$maxTrialCount" ]; do
    if [ -d "$OSInstaller" ]; then
        if [ -f "$installerPlist" ]; then
            if [ "$installerVersion_Full_Integer" -lt 110000 ]; then
                currentInstallerVersion=$(/usr/libexec/PlistBuddy -c "print 'System Image Info:version'" "$installerPlist")
            else
                currentInstallerVersion=$(/usr/libexec/PlistBuddy -c "print DTPlatformVersion" "$installerPlist")
            fi
        else
            ((loopCount++))
            /bin/echo "Installer check: Not found $installerPlist."
            /bin/echo "Try to download installer.app. ($loopCount / $maxTrialCount )"
            downloadInstaller
            continue
        fi

        if [ "$currentInstallerVersion" = "$installerVersion" ]; then
            /bin/echo "Installer check: Target version is ok ($currentInstallerVersion)."
        else
            ((loopCount++))
            /bin/echo "Installer check: Expected: $installerVersion Actual: $currentInstallerVersion"
            /bin/echo "Try to download installer.app. ($loopCount / $maxTrialCount )"
            downloadInstaller
            continue
        fi

        if [ "$doCheckDMGchecksum" = yes ]; then
            checkResult="$( verifyChecksum )"
            if [ "$checkResult" = "Valid" ]; then
                /bin/echo "Installer check: DMG file is $checkResult"
                unsuccessfulDownload=0
            else
                ((loopCount++))
                /bin/echo "Installer check: DMG file is $checkResult"
                /bin/echo "Try to download installer.app. ($loopCount / $maxTrialCount )"
                downloadInstaller
                continue
            fi
        else
            /bin/echo "Installer check: DMG file check: Skipped."
            unsuccessfulDownload=0
        fi

        /bin/echo "Installer check: PASSED"
        break
    else
        /bin/echo "Installer check: Not found installer.app."
        ((loopCount++))
        /bin/echo "Try to download installer.app. ($loopCount / $maxTrialCount )"
        downloadInstaller
    fi
done

if [ "$unsuccessfulDownload" -eq 1 ]; then
    /bin/echo "macOS Installer.app downloaded $maxTrialCount Times. But installer check failed."
    /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper \
        -windowType utility \
        -title "$title" \
        -icon "$errorIcon" \
        -iconSize 100 -button1 "OK" -defaultButton 1 \
        -heading "Error Downloading $macOSname" \
        -description "We were unable to prepare your computer for $macOSname. Please contact the IT Help Desk."
    cleanExit 0
fi
