#!/bin/zsh --no-rcs

# https://workbrew.com/docs/deployment-guides/workbrew-deployment-guide-jamf-pro

# set -x

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
  /usr/bin/sudo /usr/bin/touch "${CLT_PLACEHOLDER}"
  sleep 1
else
	echo "Xcode Command Line Tools are already installed. Checking for available updates..."
	/usr/bin/sudo /bin/rm -vf "${CLT_PLACEHOLDER}"  2>/dev/null
  sleep 1
fi
  CLT_PACKAGE=$(/usr/sbin/softwareupdate --list --force --verbose | grep -B 1 "Command Line Tools")
  CLT_PACKAGE=$(echo "$CLT_PACKAGE" | awk -F"*" '/^ *\*/ {print $2}' | sed -e 's/^ *Label: //' -e 's/^ *//' | sort -V | tail -n1)
  /usr/bin/sudo /usr/sbin/softwareupdate --install --no-scan --force --agree-to-license --verbose "${CLT_PACKAGE}"
	/usr/bin/sudo /bin/rm -vf "${CLT_PLACEHOLDER}"  2>/dev/null

exit
