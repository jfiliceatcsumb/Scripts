#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it


# This script fixes an installer design flaw in the Rave Notifier installer "Rave_Notifier_0.9.25.pkg" 
# Script creates LaunchAgent plist to include necessary key-value pairs such as KeepAlive
# The pkg postinstall script copies the LaunchAgent config into the current user’s profile ~/Library/LaunchAgents/ directory; 
# However, the correct location for a LaunchAgent plist for all users must be installed at the local domain directory for all users: /Library/LaunchAgents/

# This script requires '/Applications/Rave Notifier.app' to be installed.
# This script requires '/Applications/Rave Notifier.app/Contents/Resources/com.ale-enterprise.RaveNotifier.plist'.

# Run it with no arguments. 
# 
# Use as post install script in Jamf JSS.


# Change History:
# 2024/03/19:	Creation.
# 2024/05/07:	Rewrite to manually create LaunchAgent plist to include necessary key-value pairs such as KeepAlive
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

echo "pathToScript=$pathToScript"
echo "mountPoint=$mountPoint"
echo "computerName=$computerName"
echo "userName=$userName"


# ##### Debugging flags #####
# debug bash script by enabling verbose “-v” option
# set -v
# debug bash script using noexec (Test for syntaxt errors)
# set -n
# identify the unset variables while debugging bash script
# set -u
# debug bash script using xtrace
set -x

# Example:
# /bin/ls -FlOah "${SCRIPTDIR}"

LAUNCH_AGENT_SRC="/Applications/Rave Notifier.app/Contents/Resources/com.ale-enterprise.RaveNotifier.plist"
LAUNCH_AGENT_DST_PATH="/Library/LaunchAgents"
LAUNCH_AGENT_DST="${LAUNCH_AGENT_DST_PATH}/com.ale-enterprise.RaveNotifier.plist"

LAUNCH_AGENT_Label=$(/usr/bin/defaults read "$LAUNCH_AGENT_SRC" 'Label')
LAUNCH_AGENT_StandardErrorPath=$(/usr/bin/defaults read "$LAUNCH_AGENT_SRC" 'StandardErrorPath')
LAUNCH_AGENT_StandardOutPath=$(/usr/bin/defaults read "$LAUNCH_AGENT_SRC" 'StandardOutPath')

APP_PATH="/Applications/Rave Notifier.app"
LAUNCH_AGENT_Program="/Applications/Rave Notifier.app/Contents/MacOS/Rave Notifier"
ProcNameToKill="Rave Notifier"

UID_CURRENT=$(/usr/bin/id -u $userName)


# 	Unload and Delete old agent
if [ "${UID_CURRENT}" != "0" -a "${UID_CURRENT}" != "" ]; then
	userHome=$(eval echo ~${userName})
# 		bootout is the modern launchctlsubcommand for macOS 10.10 and newer.
# 		https://babodee.wordpress.com/2016/04/09/launchctl-2-0-syntax/
	/bin/launchctl bootout gui/${UID_CURRENT}/${LAUNCH_AGENT_Label}
	if [[ -e "${userHome}/${LAUNCH_AGENT_DST}" ]]; then
		/bin/rm -fv "${userHome}/${LAUNCH_AGENT_DST}"
	fi

fi

if [[ -e "${LAUNCH_AGENT_DST}" ]]; then
	/usr/bin/defaults delete "${LAUNCH_AGENT_DST}"
fi

# `killall -q`
# 		Suppress error message if no processes are matched. 
# 		Not supported on on older versions (e.g. macOS 11)
# 		Thus redirecting stderr to stdout instead
# `killall -v`
# 		Be verbose about what will be done
/usr/bin/killall -v "${ProcNameToKill}" 2>&1

sleep 5

# Write the LaunchAgent Plist file
/usr/bin/defaults write "${LAUNCH_AGENT_DST}" 'Label' -string "${LAUNCH_AGENT_Label}"
/usr/bin/defaults write "${LAUNCH_AGENT_DST}" 'RunAtLoad' -bool TRUE
/usr/bin/defaults write "${LAUNCH_AGENT_DST}" 'Program' -string "${LAUNCH_AGENT_Program}"
# /usr/bin/defaults write "${LAUNCH_AGENT_DST}" 'ProgramArguments' -array "open" "-a" "${APP_PATH}"
/usr/bin/defaults write "${LAUNCH_AGENT_DST}" 'KeepAlive' -bool TRUE
# /usr/bin/defaults write "${LAUNCH_AGENT_DST}" 'LimitLoadToSessionType' -string "Aqua"
/usr/bin/defaults write "${LAUNCH_AGENT_DST}" 'StandardErrorPath' -string "${LAUNCH_AGENT_StandardErrorPath}"
/usr/bin/defaults write "${LAUNCH_AGENT_DST}" 'StandardOutPath' -string "${LAUNCH_AGENT_StandardOutPath}"

echo "Reading the ${LAUNCH_AGENT_DST} values..."
/usr/bin/defaults read "${LAUNCH_AGENT_DST}"

# Set file permissions
/usr/sbin/chown -fv 0:0 "$LAUNCH_AGENT_DST"
/bin/chmod -fv 644 "$LAUNCH_AGENT_DST"

# Load new agent
if [ "${UID_CURRENT}" != "0" -a "${UID_CURRENT}" != "" ]; then
# 	bootstrap is the modern launchctl subcommand for macOS 10.10 and newer.
	/bin/launchctl enable gui/${UID_CURRENT}/${LAUNCH_AGENT_Label}
	/bin/launchctl bootstrap gui/${UID_CURRENT} "${LAUNCH_AGENT_DST}"
# 	/bin/launchctl kickstart -kp gui/${UID_CURRENT}/${LAUNCH_AGENT_Label}
	/bin/launchctl print gui/${UID_CURRENT}/${LAUNCH_AGENT_Label}
fi

################
# Expected plist values
# 
# <dict>
# 	<key>Label</key>
# 	<string>com.ale-enterprise.RaveNotifier.agent</string>
# 	<key>RunAtLoad</key>
# 	<true/>
# 	<key>Program</key>
# 	<string>/Applications/Rave Notifier.app/Contents/MacOS/Rave Notifier</string>
# 	<key>KeepAlive</key>
# 	<true/>
# 	<key>LimitLoadToSessionType</key>
# 	<string>Aqua</string>
# 	<key>StandardErrorPath</key>
# 	<string>/tmp/RaveNotifier.err</string>
# 	<key>StandardOutPath</key>
# 	<string>/tmp/RaveNotifier.out</string>
# </dict>

# ###################
#  LaunchAgent plist for RaveNotifier v.0.9.25 default values:
# 
# <dict>
# 	<key>Label</key>
# 	<string>com.ale-enterprise.RaveNotifier.agent</string>
# 
# 	<key>ProgramArguments</key>
# 	<array>
# 		<string>open</string>
# 		<string>-a</string>
# 		<string>/Applications/Rave Notifier.app</string>
# 	</array>
# 
# 	<key>RunAtLoad</key>
# 	<true/>
# 
# 	<key>StandardErrorPath</key>
# 	<string>/tmp/RaveNotifier.err</string>
# 
# 	<key>StandardOutPath</key>
# 	<string>/tmp/RaveNotifier.out</string>
# </dict>


exit 0

