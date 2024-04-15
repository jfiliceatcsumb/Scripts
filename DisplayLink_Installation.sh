#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script requires .
# Run it with no arguments. 
# 
# Use as script in Jamf JSS.
# 
# How to deploy DisplayLink macOS software within a corporation
# https://support.displaylink.com/knowledgebase/articles/820758-how-to-deploy-displaylink-macos-software-within-a
# 
# Troubleshooting: macOS
# https://support.displaylink.com/knowledgebase/topics/80209-troubleshooting-macos
# 
# End-User Cleaner Tool for macOS
# https://support.displaylink.com/knowledgebase/articles/2012213-end-user-cleaner-tool-for-macos
# 
# DisplayLink Support Tool for macOS
# https://support.displaylink.com/knowledgebase/articles/2004943-macos-ventura-13-how-to-prevent-the-login-blink-l
# https://www.synaptics.com/products/displaylink-graphics/downloads/macos-support-tool 
# 
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

exit 0

