#!/bin/zsh --no-rcs

# https://workbrew.com/docs/deployment-guides/workbrew-deployment-guide-jamf-pro

# set -x

# Get and install Xcode CLI tools
# Prerequisites: macOS 10.9.x or newer


# on 10.9+, we can leverage SUS to get the latest CLI tools

if [[ ! -f "/Library/Developer/CommandLineTools/usr/bin/git" ]]; then
	echo "Xcode Command Line Tools not found. Starting installation..."
  CLT_PLACEHOLDER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
  /usr/bin/sudo /usr/bin/touch "${CLT_PLACEHOLDER}"
fi
	echo "Xcode Command Line Tools are already installed. Checking for available updates..."
  CLT_PACKAGE="$(/usr/sbin/softwareupdate -l | grep -B 1 "Command Line Tools" | awk -F"*" '/^ *\*/ {print $2}' | sed -e 's/^ *Label: //' -e 's/^ *//' | sort -V | tail -n1)"
  /usr/bin/sudo /usr/sbin/softwareupdate --install --verbose "${CLT_PACKAGE}"
	/usr/bin/sudo /bin/rm -vf "${CLT_PLACEHOLDER}"  2>/dev/null

exit
