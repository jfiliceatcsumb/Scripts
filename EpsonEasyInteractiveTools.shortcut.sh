#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script requires .
# Run it with no arguments. 
# 
# Use as script in Jamf JSS.


# Change History:
# 2022/01/19:	Creation.
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


echo "***Begin $SCRIPTNAME script***"
/bin/date


# set -x # For debugging, show commands.

# Start here
echo 'Only If Epson Easy Interactive Tools app exists, then'
if [ -e "/Applications/Easy Interactive Tools Ver.3/Easy Interactive Tools.app" ] 
then
	echo 'Delete existing symbolic link or alias at target location; error if not exist.'
	/bin/rm -fv "${HOME}/Desktop/Easy Interactive Tools.app"

	echo 'Create symbolic link at target location.'
	/bin/ln -shfFv "/Applications/Easy Interactive Tools Ver.3/Easy Interactive Tools.app" "${HOME}/Desktop/Easy Interactive Tools.app"

	# Else, echo not found.
else
	echo 'Epson Easy Interactive Tools app not found'
fi

echo "***End $SCRIPTNAME script***"
/bin/date


exit 0

