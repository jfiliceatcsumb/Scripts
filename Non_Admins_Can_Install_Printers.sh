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
# 2017/09/26:	Creation.
#

SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

# Jamf JSS Parameters 1 through 3 are predefined as mount point, computer name, and username

pathToScript=$0
mountPoint=$1
computerName=$2
useName=$3



# set alias for PlistBuddy and several others so I don't have to specify full path.
# Prefix sudo path because I'm using it here for all commands.
# If I want to run a command without the alias, then specify the full path.
alias PlistBuddy="/usr/bin/sudo /usr/libexec/PlistBuddy"
alias chown="/usr/bin/sudo /usr/sbin/chown"
alias chmod="/usr/bin/sudo /bin/chmod"
alias ditto="/usr/bin/sudo /usr/bin/ditto"
alias defaults="/usr/bin/sudo /usr/bin/defaults"
alias rm="/usr/bin/sudo /bin/rm"
alias cp="/usr/bin/sudo /bin/cp"
alias mkdir="/usr/bin/sudo /bin/mkdir"
alias sudo=/usr/bin/sudo

# https://support.apple.com/en-us/HT200125
# https://macmule.com/2011/07/27/how-to-allow-all-users-to-add-or-remove-printers/
# https://www.jamf.com/jamf-nation/discussions/6947/os-x-10-8-non-admins-add-and-remove-printers#responseChild49059

/usr/sbin/dseditgroup -v -o edit -n /Local/Default -a everyone -t group lpadmin
/usr/bin/security -v authorizationdb write system.print.operator allow


exit 0

