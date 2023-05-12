#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it

# Pro Tools on Mac changed to a package (files contained in the app) with the 11.0 release, so an uninstaller is not included
# https://avid.secure.force.com/pkb/articles/en_US/troubleshooting/Manual-uninstall-PT11

# If reverting back to a previous version of Pro Tools (e.g. 12.0 to 11.3.1), simply move the following files to the trash to manually remove Pro Tools from a Mac system:
# Mac HD/Applications/Pro Tools (app)
# Mac HD/Library/Audio/MIDI Patch Names/Avid (folder)
# Mac HD/Library/Application Support/Propellerhead Software/Rex (folder)
# Mac HD/Library/Application Support/Avid/Audio (folder)
# Mac HD/Users/home/Library/Preferences/Avid/Pro Tools (folder)
# NOTES: 
# - The Audio folder contains "Plug-In Settings", "Plug-Ins" and "Plug-Ins (Unused)"
# - Most 3rd Party Plug-Ins are also installed in this "Plug-Ins" folder. Please back up the folders or just move to your 

# Change History:
# 2023/05/12:	Creation.
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

rm -fR "/Applications/Pro Tools.app"
rm -fR "/Library/Application Support/Avid/Audio/"*


exit 0