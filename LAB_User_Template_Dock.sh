#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Commands must run as root.
# 
# History
# 2021/08/31:	Creation.

# 				

SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

echo "***Begin $SCRIPTNAME script***"
/bin/date

#  set alias for PlistBuddy and several others so I don't have to specify full path.
# Prefix sudo path because I'm using it here for all commands.
# If I want to run a command without the alias, then specify the full path.
alias PlistBuddy="/usr/libexec/PlistBuddy"
alias chown="/usr/sbin/chown"
alias chmod="/bin/chmod"
alias ditto="/usr/bin/ditto"
alias defaults="defaults"
alias rm="/bin/rm"
alias cp="/bin/cp"
alias mkdir="/bin/mkdir"
alias mv="/bin/mv"
alias sudo=/usr/bin/sudo

# set -x # For debugging, show commands.


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

if [ $macOSversionMajor -ge 11 ] || [ $macOSversionMajor -ge 10 -a $macOSversionMinor -ge 15 ]; then
	echo "10.15 and newer"
	USER_TEMPL='/Library/User Template'
else
	echo "older than 10.15"
	USER_TEMPL='/System/Library/User Template'
fi

echo "USER_TEMPL=$USER_TEMPL"

########## FINDER ##########

mkdir -pv -m 755 "${USER_TEMPL}/Non_localized/Library/Preferences"
touch "${USER_TEMPL}/Non_localized/Library/Preferences/com.apple.dock.plist"
defaults write "${USER_TEMPL}/Non_localized/Library/Preferences/com.apple.dock.plist" ---

chmod 644 "${USER_TEMPL}/Non_localized/Library/Preferences/com.apple.dock.plist"
chown -fR 0:0 "${USER_TEMPL}"

##########  ##########


echo "***End $SCRIPTNAME script***"
/bin/date

exit 0

