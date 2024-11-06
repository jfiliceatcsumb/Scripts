#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Preinstall script to delete existing application bundle.
# For best results run preinstall script in a PKG installer.
# 
# Use as preinstall script in Jamf JSS.


# Change History:
# 2024/04/26:	Creation.
# 2024/11/04:	Modified as an uninstall script.
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
# set -x

# Example:
# /bin/ls -FlOah "${SCRIPTDIR}"
appBundleDefaultPath="/Applications/Rave Notifier.app"
appBundleID="com.ale-enterprise.RaveNotifier"
ProcNameToKill="Rave Notifier"

LAUNCH_AGENT_SRC="/Applications/Rave Notifier.app/Contents/Resources/com.ale-enterprise.RaveNotifier.plist"
LAUNCH_AGENT_DST_PATH="/Library/LaunchAgents/"
LAUNCH_AGENT_DST="${LAUNCH_AGENT_DST_PATH}com.ale-enterprise.RaveNotifier.plist"

UID_CURRENT=$(/usr/bin/id -u $userName)

# If we have not already an agent it means it's the first install
if [ ! -f "$LAUNCH_AGENT_DST" ]; then
  
#	 Copy new agent
	/bin/cp "$LAUNCH_AGENT_SRC" "$LAUNCH_AGENT_DST" || true
	/usr/sbin/chown -fv 0:0 "$LAUNCH_AGENT_DST"
	/bin/chmod -fv 644 "$LAUNCH_AGENT_DST"

else

# 	Unload and Delete old agent
	if [ "${UID_CURRENT}" != "0" -a "${UID_CURRENT}" != "" ]; then
		/bin/launchctl unload "$LAUNCH_AGENT_DST"
		/bin/launchctl bootout gui/${UID_CURRENT} "$LAUNCH_AGENT_DST"
	fi

	/bin/rm -f "$LAUNCH_AGENT_DST"
	


# `killall -q`
# 		Suppress error message if no processes are matched. 
# 		Not supported on on older versions (e.g. macOS 11)
# 		Thus redirecting stderr to stdout instead
# `killall -v`
# 		Be verbose about what will be done
/usr/bin/killall -v "${ProcNameToKill}" 2>&1

if [[ -e "$appBundleDefaultPath" ]]; then
	/bin/rm -fR "$appBundleDefaultPath"
fi

# Save found application paths as an array of strings.
# Normally, the explicit rm command above should remove the only copy installed on most systems.
appBundleIDfound=(${(f)"$(/usr/bin/mdfind  kMDItemCFBundleIdentifier="${appBundleID}")"})
# Iterate through each element of the array to delete all found copies.
for appBundlePath in ${appBundleIDfound[@]}; do
	echo "deleting ${appBundlePath}..."
	/bin/rm -fR "${appBundlePath}"
done

exit 0

