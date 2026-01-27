#!/bin/zsh --no-rcs

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it


# Use as script in Jamf JSS.
# This script requires 2 arguments:
# 
# Parameter 4 = HOMEURL
# Your PrinterLogic domain name. e.g. companyname.printercloud.com
# 
# Parameter 5 = AUTHCODE
# Authorized Device code that you generate in the Admin console.

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
# 2021/12/15:	Creation.
# 2025/02/20:	Arm64 download link. Variables
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
# 

readonly HOMEURL="${1}"
readonly AUTHCODE="${2}"

readonly PKG_EXPECTED_TEAMID='25DQ8HVJ3B'
readonly launchdPlistPath="/Library/LaunchDaemons/com.printerlogic.client.plist"

readonly CPUarch=$(/usr/bin/uname -m)
# Expected results: arm64 | i386 | x86_64

if [[ "${CPUarch}" = "arm64" ]]; then
	readonly PKGfile="PrinterInstallerClientSetup_arm64.pkg"
else
	readonly PKGfile="PrinterInstallerClientSetup.pkg"
fi

readonly PKG_URL="https://${HOMEURL}/client/setup/${PKGfile}"

if [[ -e /tmp/"${PKGfile}" ]]; then
	/bin/rm -fR /tmp/"${PKGfile}"
fi

/usr/bin/curl "${PKG_URL}" --location --silent --show-error  --output /tmp/"${PKGfile}"

if [[ -e /tmp/"${PKGfile}" ]]; then
	/usr/sbin/pkgutil --check-signature /tmp/"${PKGfile}"
	
	/usr/sbin/installer -pkg /tmp/"${PKGfile}" -target / 
else 
	echo "ERROR: ${PKGfile} not found"
	exit 1
fi 

if [[ -f /opt/PrinterInstallerClient/VERSION ]]; then
	clientVers="$(cat /opt/PrinterInstallerClient/VERSION)"
	echo "PrinterLogic client version=${clientVers}"
else
		echo "ERROR: PrinterLogic client Not Installed"
		exit 1
fi

if [[ -e /opt/PrinterInstallerClient/bin/set_home_url.sh ]]; then
	/opt/PrinterInstallerClient/bin/set_home_url.sh https ${HOMEURL}
else
	echo "ERROR: /opt/PrinterInstallerClient/bin/set_home_url.sh not found"
	exit 1
fi

if [[ -e /opt/PrinterInstallerClient/bin/use_authorization_code.sh ]]; then
	/opt/PrinterInstallerClient/bin/use_authorization_code.sh ${AUTHCODE}
else
	echo "ERROR: /opt/PrinterInstallerClient/bin/use_authorization_code.sh not found"
	exit 1
fi	

# Echo 

sleep 5

echo "Safari feature fix..."

if [[ -f "${launchdPlistPath}" ]]; then
	/bin/launchctl bootout system "${launchdPlistPath}" 2>&1
fi

sleep 1

if [[ -f "${launchdPlistPath}" ]]; then
	/bin/launchctl bootstrap system "${launchdPlistPath}" 2>&1
fi

sleep 1


if [[ "$userName" != "" ]] && [[ -x /opt/PrinterInstallerClient/bin/refresh.sh ]]
then
# As root
	/usr/bin/killall -KILL -v PrinterInstallerClient 2>&1
	sleep 2
	echo "running /opt/PrinterInstallerClient/bin/refresh.sh to restart the Printer Installer Client Menu Bar..."
	/opt/PrinterInstallerClient/bin/refresh.sh
fi


exit 0
