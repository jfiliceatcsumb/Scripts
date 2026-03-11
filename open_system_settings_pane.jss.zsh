#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Run it with software update identifiers arguments. The script uses quoting to keep spaces in the identifier names.
# 
# Use as script in Jamf JSS.


# Change History:
# 2026/03/11:	Creation.
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

# Find the path to SoftwareUpdate.prefPane
PrefPane=""
PrefPane="${1}"

# convenience function to run a command as the current user
# https://scriptingosx.com/2020/08/running-a-command-as-another-user/
# usage:
#   runAsUser command arguments...
runAsUser() {  
  if [ "$currentUser" != "loginwindow" ]; then
    launchctl asuser "$uid" sudo -u "$currentUser" "$@"
  else
    echo "no user logged in"
    # uncomment the exit command
    # to make the function exit with an error when no user is logged in
    # exit 1
  fi
}

/usr/bin/su -l "$userName" -c "/usr/bin/open -b com.apple.systempreferences"
/usr/bin/su -l "$userName" -c "/usr/bin/open x-apple.systempreferences:com.apple.preference.universalaccess"
/usr/bin/su -l "$userName" -c "/usr/bin/open x-apple.systempreferences:com.apple.Accessibility-Settings.extension"
/usr/bin/su -l "$userName" -c "/usr/bin/open -b com.apple.systempreferences"

# -n  
# 		Open a new instance of the application(s) even if one is already running.
# -b bundle_identifier
#		Specifies the bundle identifier for the application to use when opening the file
 