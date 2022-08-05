#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it


# NVivo PPPC Disk Access fix

# Run it with no arguments. 
# 
# Use as script in Jamf JSS.


# Change History:
# 2022/08/05:	Creation.
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

echo pathToScript=$pathToScript
echo mountPoint=$mountPoint
echo computerName=$computerName
echo userName=$userName

# set alias for PlistBuddy and several others so I don't have to specify full path.
# Prefix sudo path because I'm using it here for all commands.
# If I want to run a command without the alias, then specify the full path.
alias PlistBuddy="/usr/libexec/PlistBuddy"
alias chown="/usr/sbin/chown"
alias chmod="/bin/chmod"
alias ditto="/usr/bin/ditto"
alias defaults="/usr/bin/defaults"
alias rm="/bin/rm"
alias cp="/bin/cp"
alias mkdir="/bin/mkdir"
alias sudo=/usr/bin/sudo


# https://forums.nvivobyqsr.com/topic/10209-i-have-given-nvivo-full-disk-access-but-it-still-will-not-open/
# https://forums.nvivobyqsr.com/topic/10476-full-disk-access-issues-blocking-enterprise-installation-of-nvivo-12-and-nvivo-2020-on-macos-monterey-1231/
# https://forums.nvivobyqsr.com/topic/11086-cant-access-nvivo-on-macbook-air-running-macos-monterey-124/

# ~/Library/Safari/CloudTabs.db

# Example:
# /bin/ls -FlOah "${SCRIPTDIR}"

exit 0

