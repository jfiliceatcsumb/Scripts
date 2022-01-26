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
# 2022/01/19:	Creation.
# 2022/01/26:	Fixed chmod, chown of symbolic link.
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

echo pathToScript=$pathToScript
echo mountPoint=$mountPoint
echo computerName=$computerName
echo userName=$userName

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


echo "***Begin $SCRIPTNAME script***"
/bin/date


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

echo 'Only If Epson Easy Interactive Tools app exists, then'
if [ -e "/Applications/Easy Interactive Tools Ver.5/Easy Interactive Tools.app" ] 
then
	mkdir -pv -m 755 "${USER_TEMPL}/Non_localized/Desktop"
	
	echo 'Delete existing symbolic link or alias at target location; error if not exist.'
	/bin/rm -fv "${USER_TEMPL}/Non_localized/Desktop/Easy Interactive Tools.app"

	echo 'Create symbolic link at target location.'
	/bin/ln -shfFv "/Applications/Easy Interactive Tools Ver.5/Easy Interactive Tools.app" "${USER_TEMPL}/Non_localized/Desktop/Easy Interactive Tools.app"

	chmod -fRhPv 755 "${USER_TEMPL}/Non_localized/Desktop/Easy Interactive Tools.app"
	chown -fRhPv 0:0 "${USER_TEMPL}/Non_localized/Desktop/Easy Interactive Tools.app"

elif [ -e "/Applications/Easy Interactive Tools Ver.4/Easy Interactive Tools.app" ] 
then
	mkdir -pv -m 755 "${USER_TEMPL}/Non_localized/Desktop"
	
	echo 'Delete existing symbolic link or alias at target location; error if not exist.'
	/bin/rm -fv "${USER_TEMPL}/Non_localized/Desktop/Easy Interactive Tools.app"

	echo 'Create symbolic link at target location.'
	/bin/ln -shfFv "/Applications/Easy Interactive Tools Ver.4/Easy Interactive Tools.app" "${USER_TEMPL}/Non_localized/Desktop/Easy Interactive Tools.app"

	chmod -fRhPv 755 "${USER_TEMPL}/Non_localized/Desktop/Easy Interactive Tools.app"
	chown -fRhPv 0:0 "${USER_TEMPL}/Non_localized/Desktop/Easy Interactive Tools.app"


elif [ -e "/Applications/Easy Interactive Tools Ver.3/Easy Interactive Tools.app" ] 
then
	mkdir -pv -m 755 "${USER_TEMPL}/Non_localized/Desktop"
	
	echo 'Delete existing symbolic link or alias at target location; error if not exist.'
	/bin/rm -fv "${USER_TEMPL}/Non_localized/Desktop/Easy Interactive Tools.app"

	echo 'Create symbolic link at target location.'
	/bin/ln -shfFv "/Applications/Easy Interactive Tools Ver.3/Easy Interactive Tools.app" "${USER_TEMPL}/Non_localized/Desktop/Easy Interactive Tools.app"

	chmod -fRhPv 755 "${USER_TEMPL}/Non_localized/Desktop/Easy Interactive Tools.app"
	chown -fRhPv 0:0 "${USER_TEMPL}/Non_localized/Desktop/Easy Interactive Tools.app"


	# Else, echo not found.
else
	echo 'Epson Easy Interactive Tools app not found'
fi

echo "***End $SCRIPTNAME script***"
/bin/date


exit 0
