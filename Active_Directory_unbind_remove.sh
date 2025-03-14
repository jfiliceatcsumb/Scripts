#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script requires username and password of a Domain account that has administrative privileges to add/remove this computer to/from the Domain.


# Use as script in Jamf JSS.


# Change History:
# 2019/02/26:	Creation.
#

SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

# Jamf JSS Parameters 1 through 3 are predefined as mount point, computer name, and username

pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3

shift 3
# Shift off the $1 $2 $3 parameters passed by the JSS so that parameter 4 is now $1

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


# Example:
# /bin/ls -FlOah "${SCRIPTPATH}"

# Leaves the current domain (Removes this computer record from the current Domain).
/usr/sbin/dsconfigad -force -remove -username "$1" -password "$2"

# Sleep 5 seconds to give time to complete the transaction.
sleep 10

exit 0

