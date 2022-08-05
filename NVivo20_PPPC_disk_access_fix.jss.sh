#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it


# NVivo PPPC Disk Access fix

# Run it with no arguments. 
# 
# Use as script in Jamf JSS.


# Change History:
# 2022/08/05:	Creation.
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

# set alias for PlistBuddy and several others so I don't have to specify full path.
# Prefix sudo path because I'm using it here for all commands.
# If I want to run a command without the alias, then specify the full path.
alias PlistBuddy="/usr/libexec/PlistBuddy"
alias chown="/usr/sbin/chown"
alias chmod="/bin/chmod"
alias ditto="/usr/bin/ditto"
alias defaults="/usr/bin/defaults"
alias rm="/bin/rm"
alias cp="/bin/cp"
alias mkdir="/bin/mkdir"
alias sudo=/usr/bin/sudo


# https://forums.nvivobyqsr.com/topic/10209-i-have-given-nvivo-full-disk-access-but-it-still-will-not-open/
# https://forums.nvivobyqsr.com/topic/10476-full-disk-access-issues-blocking-enterprise-installation-of-nvivo-12-and-nvivo-2020-on-macos-monterey-1231/
# https://forums.nvivobyqsr.com/topic/11086-cant-access-nvivo-on-macbook-air-running-macos-monterey-124/

# NVivo 20 expects there exists a file in the user's directory at 
# ~/Library/Safari/CloudTabs.db

# ##### User Template #####
osXversion=$(sw_vers -productVersion)
echo "osXversion=$osXversion"
# Just get the second version value after 10.
macOSversionMajor=$(echo $osXversion | awk -F. '{print $1}')
macOSversionMinor=$(echo $osXversion | awk -F. '{print $2}')
echo "macOSversionMajor=$macOSversionMajor"
echo "macOSversionMinor=$macOSversionMinor"

# if 
# macOS 11.x or newer
# or
# macOS 10.15.x or newer

if [ $macOSversionMajor -gt 10 ] || [ $macOSversionMajor -eq 10 -a $macOSversionMinor -ge 15 ]; then
	echo "10.15 and newer"
	USER_TEMPL='/Library/User Template/Non_localized'
else
	echo "older than 10.15"
	USER_TEMPL='/System/Library/User Template/Non_localized'
fi

echo "USER_TEMPL=$USER_TEMPL"

/bin/mkdir -pv -m 755 "${USER_TEMPL}/Library/Safari"
/usr/bin/touch "${USER_TEMPL}/Library/Safari/CloudTabs.db"
/bin/chmod 644 "${USER_TEMPL}/Library/Safari/CloudTabs.db"
/usr/sbin/chown 0:0 "${USER_TEMPL}/Library/Safari/CloudTabs.db"


# ##### Current User #####
if [ $userName != "" ]
then
	
	/bin/mkdir -pv -m 755 "${userName}/Library/Safari"
	/usr/bin/touch "${userName}/Library/Safari/CloudTabs.db"
	/bin/chmod -f 644 "${userName}/Library/Safari/CloudTabs.db"
	/usr/sbin/chown -fR $userName "${userName}/Library/Safari/"
fi


exit 0

