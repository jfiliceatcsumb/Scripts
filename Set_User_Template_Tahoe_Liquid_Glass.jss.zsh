#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Sets the default user template Interface Style to Dark Mode.
# Run it with no arguments. 
# 
# Use as script in Jamf JSS.


# Change History:
# 2024/08/22:	Creation.
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

echo "pathToScript=$pathToScript"
echo "mountPoint=$mountPoint"
echo "computerName=$computerName"
echo "userName=$userName"


# ##### Debugging flags #####
# debug bash script by enabling verbose “-v” option
# set -v
# debug bash script using noexec (Test for syntaxt errors)
# set -n
# identify the unset variables while debugging bash script
# set -u
# debug bash script using xtrace
# set -x

# Liquid Glass Tinted 
# Template 

/bin/mkdir -p -m 0755 "/Library/User Template/Non_localized/Library/Preferences/"
/usr/bin/defaults write "/Library/User Template/Non_localized/Library/Preferences/.GlobalPreferences.plist" NSGlassDiffusionSetting -bool true
/usr/sbin/chown 0:0 "/Library/User Template/Non_localized/Library/Preferences/.GlobalPreferences.plist"

echo "read GlobalPreferences.plist"
/usr/bin/defaults read "/Library/User Template/Non_localized/Library/Preferences/.GlobalPreferences.plist"

# ~admin
/usr/bin/defaults write "/Users/admin/Library/Preferences/.GlobalPreferences.plist" NSGlassDiffusionSetting -bool
/usr/sbin/chown 0:0 "/Users/admin/Library/Preferences/.GlobalPreferences.plist"

echo "read GlobalPreferences.plist"
/usr/bin/defaults read "/Users/admin/Library/Preferences/.GlobalPreferences.plist"

# Reduce transparency
# com.apple.universalaccess.plist
# 	<key>reduceTransparency</key>
# 	<true/>

/bin/mkdir -p -m 0755 "/Library/User Template/Non_localized/Library/Preferences/"
/usr/bin/defaults write "/Library/User Template/Non_localized/Library/Preferences/com.apple.universalaccess.plist" NSGlassDiffusionSetting -bool true
/usr/sbin/chown 0:0 "/Library/User Template/Non_localized/Library/Preferences/com.apple.universalaccess.plist"
echo "read com.apple.universalaccess.plist"
/usr/bin/defaults read "/Library/User Template/Non_localized/Library/Preferences/com.apple.universalaccess.plist"

# Differentiate without color
# com.apple.universalaccess.plist
# 	<key>differentiateWithoutColor</key>
# 	<true/>

# Show window title icons
# com.apple.universalaccess.plist
# 	<key>showWindowTitlebarIcons</key>
# 	<true/>


exit 


