#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Run it with no arguments. 
# 
# Use as script in Jamf JSS.



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
# https://www.reddit.com/r/macsysadmin/comments/xqib52/anyway_to_allow_non_admins_to_add_a_printer_macos/

date_stamp=$(date -u +"%F-%H-%M-%S")
BackupDirectory=/usr/local/share/authorizationdb.backup

mkdir -p "${BackupDirectory}"

# backup
/usr/bin/security -v authorizationdb read system.preferences > ${BackupDirectory}/${date_stamp}.system.preferences.plist
/usr/bin/security -v authorizationdb read system.preferences.printing > ${BackupDirectory}/${date_stamp}.system.preferences.printing.plist

# unlock the sysprefs before unlocking specific panes: 
/usr/bin/security -v authorizationdb write system.preferences allow 

# unlock printing: 
/usr/bin/security -v authorizationdb write system.preferences.printing allow

# Added for macOS 12 Monterey (and Big Sur?)
/usr/bin/security -v authorizationdb write system.print.operator allow
/usr/sbin/dseditgroup -o edit -n /Local/Default -a everyone -t group lpadmin
/usr/sbin/dseditgroup -o edit -n /Local/Default -a everyone -t group _lpadmin

exit 0

