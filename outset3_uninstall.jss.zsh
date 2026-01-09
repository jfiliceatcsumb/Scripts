#!/bin/zsh --no-rcs
# 

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Run it with no arguments. 
# Run with root privileges
# Use as script in Jamf JSS.

# https://github.com/chilcote/outset/wiki/FAQ#how-can-i-remove-outset

# Change History:
# 2026/01/08:	Creation.
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
{ set -x; } 2>/dev/null
# Disable tracing without trace output
# { set +x; } 2>/dev/null

# Example:
# /bin/ls -FlOah "${SCRIPTDIR}"

/usr/bin/sudo /bin/launchctl bootout  system/com.github.outset.boot 2>&1
/usr/bin/sudo /bin/launchctl unload "/Library/LaunchDaemons/com.github.outset.boot.plist" 2>&1
/usr/bin/sudo /bin/rm -fv "/Library/LaunchDaemons/com.github.outset.boot.plist" 2>&1
/usr/bin/sudo /bin/launchctl bootout  system/com.github.outset.cleanup 2>&1
/usr/bin/sudo /bin/launchctl unload "/Library/LaunchDaemons/com.github.outset.cleanup.plist" 2>&1
/usr/bin/sudo /bin/rm -fv "/Library/LaunchDaemons/com.github.outset.cleanup.plist" 2>&1
/usr/bin/sudo /bin/launchctl bootout  system/com.github.outset.login 2>&1
/usr/bin/sudo /bin/launchctl unload "/Library/LaunchAgents/com.github.outset.login.plist" 2>&1
/usr/bin/sudo /bin/rm -fv "/Library/LaunchAgents/com.github.outset.login.plist" 2>&1
/usr/bin/sudo /bin/launchctl bootout  system/com.github.outset.on-demand 2>&1
/usr/bin/sudo /bin/launchctl unload "/Library/LaunchAgents/com.github.outset.on-demand.plist" 2>&1
/usr/bin/sudo /bin/rm -fv "/Library/LaunchAgents/com.github.outset.on-demand.plist" 2>&1
/usr/bin/sudo /bin/rm -rfv /usr/local/outset 2>&1
/usr/bin/sudo /usr/sbin/pkgutil --forget com.github.outset 2>&1

exit 0

