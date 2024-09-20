#!/bin/bash

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

set -x

echo pathToScript=$pathToScript
echo mountPoint=$mountPoint
echo computerName=$computerName
echo userName=$userName


# Example:
# /bin/ls -FlOah "${SCRIPTDIR}"

HOMEURL="${1}"
AUTHCODE="${2}"
/usr/bin/curl "https://${HOMEURL}/client/setup/PrinterInstallerClientSetup.pkg" --location --silent --show-error  --output /tmp/PrinterInstallerClientSetup.pkg 
/usr/sbin/installer -allowUntrusted -pkg /tmp/PrinterInstallerClientSetup.pkg -target /
/opt/PrinterInstallerClient/bin/set_home_url.sh https ${HOMEURL}
/opt/PrinterInstallerClient/bin/use_authorization_code.sh ${AUTHCODE}

# Echo 
clientVers="$(cat /opt/PrinterInstallerClient/VERSION)"
echo "PrinterLogic client version=$clientVers"

# Safari feature

if [[ "$userName" != "" ]]
then
# As root
	/usr/bin/killall PrinterInstallerClient

# Must run as user $userName
	/usr/bin/sudo --user=${userName} /bin/sh -c "/usr/bin/open $(cat /etc/pl_dir)/service_interface/PrinterInstallerClient.app"
    # su -l ${userName} -c "echo"
fi
