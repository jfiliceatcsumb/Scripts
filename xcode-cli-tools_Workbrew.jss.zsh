#!/bin/zsh --no-rcs

# https://workbrew.com/docs/deployment-guides/workbrew-deployment-guide-jamf-pro

# ##### Debugging flags #####
# debug bash script by enabling verbose “-v” option
# set -v
# debug bash script using noexec (Test for syntaxt errors)
# set -n
# identify the unset variables while debugging bash script
# set -u
# debug bash script using xtrace
# set -x
# Enable tracing without trace output
# { set -x; } 2>/dev/null
# Disable tracing without trace output
# { set +x; } 2>/dev/null

# Get and install Xcode CLI tools
# Prerequisites: macOS 10.13.4 or newer

macOSversion=$(sw_vers -productVersion)

echo "macOSversion=${macOSversion}"
# Just get the second version value after 10.
macOSversionMajor=$(echo ${macOSversion} | awk -F. '{print $1}')
macOSversionMinor=$(echo ${macOSversion} | awk -F. '{print $2}')
macOSversionMinorUpdate=$(echo ${macOSversion} | awk -F. '{print $3}')
echo "macOSversionMajor=${macOSversionMajor}"
echo "macOSversionMinor=${macOSversionMinor}"
echo "macOSversionMinorUpdate=${macOSversionMinorUpdate}"


if [[ ${macOSversionMajor} -eq 10 && ${macOSversionMinor} -lt 13 ]] || [[ ${macOSversionMajor} -eq 10 && ${macOSversionMinor} -eq 13 && ${macOSversionMinorUpdate} -lt 4 ]]; then
	echo "ERROR: Prerequisites macOS 10.13.4 or newer. Terminating script." 1>&2
	exit 1
fi
# on 10.9+, we can leverage SUS to get the latest CLI tools

CLT_PLACEHOLDER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
if [[ ! -f "/Library/Developer/CommandLineTools/usr/bin/git" ]]; then
	echo "Xcode Command Line Tools not found. Starting installation..."
#  Touch the Apple placeholder flag
	/usr/bin/touch "${CLT_PLACEHOLDER}"
  sleep 1
else
	echo "Xcode Command Line Tools are already installed. Checking for available updates..."
	/bin/rm -vf "${CLT_PLACEHOLDER}"  2>/dev/null
fi


# 3. Force a quick scan to populate the local softwareupdate history
/usr/sbin/softwareupdate -l > /dev/null 2>&1
 																						
# Extract the exact matching package name from the Apple Catalog
CLT_PACKAGE=$(/usr/sbin/softwareupdate -l | grep -B 1 "Command Line Tools" | awk -F"*" '/^ *\*/ {print $2}' | sed -e 's/^ *Label: //' -e 's/^ *//' | sort -V | tail -n1)

if [ -z "$CLT_PACKAGE" ]; then
    echo "ERROR: No Command Line Tools found in the Apple catalog stream."
    /bin/rm -f "${CLT_PLACEHOLDER}" 2>/dev/null
    exit 1
fi

echo "Targeting package: ${CLT_PACKAGE}"


#  Detect if a user is currently logged into the GUI console
CURRENT_USER=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ {print $3}')

if [ -n "${CURRENT_USER}" ] && [ "${CURRENT_USER}" != "_mbsetupuser" ]; then
    echo "User '${CURRENT_USER}' is logged in. Executing within the user context to prevent GUI freeze..."
    # Running via launchctl inside the user's bootstrap bypasses the root MDM lock
    USER_ID=$(id -u "${CURRENT_USER}")
    launchctl asuser "${USER_ID}" /usr/sbin/softwareupdate --install "${CLT_PACKAGE}" --verbose
else
    echo "No user logged in (Headless / Login Window). Executing directly as system root..."
    # Since no user session exists, the root process can claim the update daemon directly
    /usr/sbin/softwareupdate --install "${CLT_PACKAGE}" --verbose
fi

#  Cleanup and verification
/bin/rm -vf "${CLT_PLACEHOLDER}"  2>/dev/null

if [ -d "/Library/Developer/CommandLineTools/usr/bin" ]; then
    echo "Success: Command Line Tools successfully installed."
    exit 0
else
    echo "ERROR: Installation completed but binaries were not found."
    exit 2
fi

exit
