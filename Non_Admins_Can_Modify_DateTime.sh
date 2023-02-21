#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Run it with no arguments. 
# 
# Use as script in Jamf JSS.


# Change History:
# 2020/03/24:	Creation.
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
alias PlistBuddy="/usr/libexec/PlistBuddy"
alias chown="/usr/sbin/chown"
alias chmod="bin/chmod"
alias ditto="/usr/bin/ditto"
alias defaults="/usr/bin/defaults"
alias rm="/bin/rm"
alias cp="/bin/cp"
alias mkdir="/bin/mkdir"
alias sudo=/usr/bin/sudo
alias security=/usr/bin/security

# https://derflounder.wordpress.com/2014/02/16/managing-the-authorization-database-in-os-x-mavericks/
# https://www.jamf.com/jamf-nation/discussions/20713/allow-security-preference-pane-non-admin#responseChild125140
# https://www.jamf.com/jamf-nation/discussions/34153/unlock-energy-saver-prefs-for-non-admins#responseChild195761

date_stamp=$(date -u +"%F-%H-%M-%S")
BackupDirectory=/usr/local/share/authorizationdb.backup

mkdir -p "${BackupDirectory}"

# backup
security -v authorizationdb read system.preferences > ${BackupDirectory}/${date_stamp}.system.preferences.plist
# unlock the sysprefs before unlocking specific panes: 
security -v authorizationdb write system.preferences allow 

# backup
security -v authorizationdb read system.preferences.datetime > ${BackupDirectory}/${date_stamp}.system.preferences.datetime.plist
# unlock date & time: 
security -v authorizationdb write system.preferences.datetime allow
security -v authorizationdb write system.preferences.dateandtime.changetimezone allow

exit 0
