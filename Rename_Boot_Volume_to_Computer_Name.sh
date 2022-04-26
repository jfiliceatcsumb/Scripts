#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# http://csumb.edu/it


# This script will rename the hard drive name to match the computer name.
# It should be used after the Computer Hostname task.
# Do not use `/bin/hostname -s` because that is not always the computer name.

# Change History:
# 2015/12/03:	Get the computer name in all caps. Also set the computer name to the all caps name.	
# 2016/08/16:	Added bless command to fix problem with Mac losing startup disk after reboot.
# 2016/08/31:	Specify local host name based on computer name. We found several Macs getting their local host name truncated.


SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

echo "***Begin $SCRIPTNAME script***"
/bin/date

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


# Get the computer name. Also set the computer name to the all caps name.

COMPUTERNAME=$(/usr/sbin/scutil --get ComputerName | /usr/bin/sed -e 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/' )
# echo '$COMPUTERNAME=' $COMPUTERNAME

# set -x 

echo Computer Name: "${COMPUTERNAME}"
/usr/sbin/diskutil renameVolume / "${COMPUTERNAME}"

/usr/sbin/bless --mount / --setBoot

echo LocalHost Name:  `/usr/sbin/scutil --get LocalHostName`

echo Computer Name: `/usr/sbin/scutil --get ComputerName`

/usr/sbin/bless --info --getBoot 

# set +x

echo "***End $SCRIPTNAME script***"
/bin/date

exit 0
