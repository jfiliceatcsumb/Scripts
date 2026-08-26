#!/bin/bash --noprofile --norc

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


# https://derflounder.wordpress.com/2014/02/16/managing-the-authorization-database-in-os-x-mavericks/
# https://www.jamf.com/jamf-nation/discussions/20713/allow-security-preference-pane-non-admin#responseChild125140
# https://www.jamf.com/jamf-nation/discussions/34153/unlock-energy-saver-prefs-for-non-admins#responseChild195761

date_stamp=$(date -u +"%F-%H-%M-%S")
BackupDirectory='/usr/local/share/authorizationdb.backup'
# Define the targets in the macOS Authorization Database
TARGET_RIGHT_1="system.preferences.accessibility"
TARGET_RIGHT_2="com.apple.speech.recognition"

echo "Modifying authorizationdb to allow standard users to toggle accessibility..."

mkdir -p "${BackupDirectory}"

# backup
security -v authorizationdb read "${TARGET_RIGHT_1}"  > ${BackupDirectory}/${date_stamp}.${TARGET_RIGHT_1}.plist
# Change the accessibility preference pane rule to allow all users
security -v authorizationdb write "${TARGET_RIGHT_1}" allow 

# backup
security -v authorizationdb read "${TARGET_RIGHT_2}"  > ${BackupDirectory}/${date_stamp}.${TARGET_RIGHT_2}.plist
# Change the dictation/voice control security rule to allow all users
security -v authorizationdb write "${TARGET_RIGHT_2}" allow 

echo "Authorization database updated successfully."

exit
