#!/bin/zsh --no-rcs

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script requires bundle identifier (e.g. com.apple.TextEdit) as argument.
# 
# Use as script in Jamf JSS.


# Change History:
# 2019/05/13	Creation.
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


# Example:
# /bin/ls -FlOah "${SCRIPTPATH}"

bundle_indentifier="$1"
/usr/bin/sudo --user=$userName /usr/bin/open -b "$bundle_indentifier"


