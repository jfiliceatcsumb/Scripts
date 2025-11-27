#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Run it with software update identifiers arguments. The script uses quoting to keep spaces in the identifier names.
# 
# Use as script in Jamf JSS.



SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

# Jamf JSS Parameters 1 through 3 are predefined as mount point, computer name, and username

pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3


shift 3
# Shift off the $1 $2 $3 parameters passed by the JSS so that parameter 4 is now $1

echo "List all available updates..."
/usr/sbin/softwareupdate --list

# loop over parameters passed
while [ $# != 0 ]
do
	# Use if,then to check for any value in the variable.
	if [ "$1" != "" ]
	then
		echo "Downloading update for ${1}..."
        /usr/sbin/softwareupdate --download "$1"
		sleep 1
		echo "Installing update for ${1}..."
		/usr/sbin/softwareupdate --install "$1"
	fi
	shift
done

exit 0


# https://developer.apple.com/library/mac/documentation/darwin/reference/manpages/man8/softwareupdate.8.html
# The --list output shows the item names you can specify here, prefixed by the * or - characters.
#
#     --ignore identifier ...
#                 Manages the per-machine list of ignored updates. The identifier is the first part of the
#                 item name (before the dash and version number) that is shown by --list.  See EXAMPLES.
# EXAMPLES
#      The following examples are shown as given to the shell:
# 
#      softwareupdate --list
# 
#            Software Update Tool
#            Copyright 2002-2012 Apple Inc.
# 
#            Finding available software
#            Software Update found the following new or updated software:
#               * MacBookAirEFIUpdate2.4-2.4
#                    MacBook Air EFI Firmware Update (2.4), 3817K [recommended] [restart]
#               * ProAppsQTCodecs-1.0
#                    ProApps QuickTime codecs (1.0), 968K [recommended]
#               * JavaForOSX-1.0
#                    Java for OS X 2012-005 (1.0), 65288K [recommended]
#      sudo softwareupdate --ignore JavaForOSX
# 
#            Ignored updates:
#            (JavaForOSX)
# 

