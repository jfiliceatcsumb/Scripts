#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it


# This script fixes an installer design flaw in the Rave Notifier installer "Rave_Notifier_0.9.25.pkg" 
# The pkg postinstall script copies the LaunchAgent config into the current user’s profile ~/Library/LaunchAgents/ directory; 
# this must be installed instead at the local domain directory for all users: /Library/LaunchAgents/
# The script below is modified from the Rave_Notifier_0.9.25.pkg postinstall script.

# This script requires '/Applications/Rave Notifier.app' to be installed.
# This script requires '/Applications/Rave Notifier.app/Contents/Resources/com.ale-enterprise.RaveNotifier.plist'.

# Run it with no arguments. 
# 
# Use as script in Jamf JSS.


# Change History:
# 2024/03/19:	Creation.
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

LAUNCH_AGENT_SRC="/Applications/Rave Notifier.app/Contents/Resources/com.ale-enterprise.RaveNotifier.plist"
LAUNCH_AGENT_DST_PATH="/Library/LaunchAgents/"
LAUNCH_AGENT_DST="${LAUNCH_AGENT_DST_PATH}com.ale-enterprise.RaveNotifier.plist"

# If we have not already an agent it means it's the first install
if [ ! -f "$LAUNCH_AGENT_DST" ]; then
  
#	 Copy and Load new agent
	/bin/cp "$LAUNCH_AGENT_SRC" "$LAUNCH_AGENT_DST" || true
	/usr/sbin/chown -fv 0:0 "$LAUNCH_AGENT_DST"
	/bin/chmod -fv 644 "$LAUNCH_AGENT_DST"
	/bin/launchctl load "$LAUNCH_AGENT_DST" || true
  
# 	Start app, since it's the first install
	/usr/bin/open -a 'Rave Notifier.app'

else

# 	Unload and Delete old agent
	/bin/launchctl unload "$LAUNCH_AGENT_DST"
	/bin/rm -f "$LAUNCH_AGENT_DST"
	
# 	Copy and Load new agent
	/bin/cp -f "$LAUNCH_AGENT_SRC" "$LAUNCH_AGENT_DST" || true
	/usr/sbin/chown -fv 0:0 "$LAUNCH_AGENT_DST"
	/bin/chmod -fv 644 "$LAUNCH_AGENT_DST"

	/bin/launchctl load "$LAUNCH_AGENT_DST" || true
  
# 	Here it's not necessary to start app ...

fi


exit 0

