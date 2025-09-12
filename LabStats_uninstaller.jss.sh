#!/bin/bash --noprofile --norc


# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it

# This script removes components of the LabStats client.
# Run it with no arguments. 
# Use as script in Jamf JSS.
# Orignal source:
# https://support.labstats.com/knowledge-base/uninstall-the-labstats-client/

# Change History:
# 2025/09/11:	Creation.
#

SCRIPTNAME=$(/usr/bin/basename "$0")
SCRIPTDIR=$(/usr/bin/dirname "$0")

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


if [ -f /Library/LaunchDaemons/labstatsgo.plist ]; then
  /bin/launchctl unload /Library/LaunchDaemons/labstatsgo.plist
fi

if [ -f /Library/LaunchAgents/labstatsgo.plist ]; then
  /usr/bin/sudo -u daemon launchctl unload /Library/LaunchAgents/labstatsgo.plist
fi

if [ -f /Library/LaunchDaemons/labstatsgo.plist ]; then
  /bin/rm -f /Library/LaunchDaemons/labstatsgo.plist
fi

if [ -f /Library/LaunchAgents/labstatsgo.plist ]; then
  /bin/rm -f /Library/LaunchAgents/labstatsgo.plist
fi

/usr/bin/pkill LabStatsGoUserSpace

if [ -f /usr/local/bin/LabStatsGoClient ]; then
  /bin/rm -f /usr/local/bin/LabStatsGoClient
fi

if [ -f /usr/local/bin/LabStatsGoUserSpace ]; then
  /bin/rm -f /usr/local/bin/LabStatsGoUserSpace
fi

/bin/rm -rf /Library/Application\ Support/LabStatsGo

echo "Uninstall successful!"
