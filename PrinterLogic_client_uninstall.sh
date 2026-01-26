#!/bin/zsh --no-rcs

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it


# Use as script in Jamf JSS.

# 
# ##### Product Documentation #####
# 
# https://help.printerlogic.com/saas/1-Printerlogic/Release_Notes/SaaS.htm
# 
# https://kb.printerlogic.com/s/article/Script-to-install-upgrade-Mac
# https://help.printerlogic.com/saas/Print/Print_Mgmt/Client_Mgmt/Workstation-Install.htm
# https://help.printerlogic.com/saas/Print/Print_Mgmt/Client_Mgmt/Additional-Client-Options.htm
# https://help.printerlogic.com/saas/Print/Setup/Client-Install.htm
# https://help.printerlogic.com/saas/Print/Setup/Client-Install.htm
# https://help.printerlogic.com/saas/1-Printerlogic/Release_Notes/SaaS.htm
# https://kb.printerlogic.com/s/article/What-Mac-OS-versions-are-supported-by-Printerlogic
# https://kb.printerlogic.com/s/article/How-to-manually-enable-the-Safari-extension-from-a-terminal
# https://kb.printerlogic.com/s/article/How-to-uninstall-Mac-client
# https://kb.printerlogic.com/s/article/Deploy-the-PrinterLogic-Chrome-Extension-via-GPO
# https://kb.printerlogic.com/s/article/How-to-manually-enable-the-Safari-extension-from-a-terminal
# https://kb.printerlogic.com/s/article/How-to-upload-Mac-drivers
# https://kb.printerlogic.com/s/article/How-to-pull-down-and-install-the-Windows-client-using-a-script
# https://kb.printerlogic.com/s/article/CouldnotcommunicatewiththePrinterLogicclientItmaynotbeinstalledorrunning
# https://kb.printerlogic.com/s/article/Unable-to-install-client-Apple-cannot-check-for-malicious-software

# 



# Change History:
# 2025/01/21:	Creation.
# 2025/02/20:	Improved checks for existing files.
# 				Forcing return exit 0 so that policies do not detect a false fail condition.
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

# set -x

echo pathToScript=$pathToScript
echo mountPoint=$mountPoint
echo computerName=$computerName
echo userName=$userName


# Example:
# /bin/ls -FlOah "${SCRIPTDIR}"

# Echo 
if [[ -f /opt/PrinterInstallerClient/VERSION ]]; then
	clientVers="$(cat /opt/PrinterInstallerClient/VERSION)"
	echo "PrinterLogic client version=${clientVers}"
else
		echo "PrinterLogic client Not Installed"
fi

if [[ -f "/Library/LaunchDaemons/com.printerlogic.client.plist" ]]; then
	/bin/launchctl bootout system "/Library/LaunchDaemons/com.printerlogic.client.plist"
fi

# As root
/usr/bin/killall -KILL PrinterInstallerClient > /dev/null 2>&1


if [[ -f /opt/PrinterInstallerClient/bin/uninstall.sh ]]; then
	echo "Running uninstall script /opt/PrinterInstallerClient/bin/uninstall.sh ..."
	/opt/PrinterInstallerClient/bin/uninstall.sh
else
		echo "Uninstall script not found at /opt/PrinterInstallerClient/bin/uninstall.sh"
fi

exit 0
