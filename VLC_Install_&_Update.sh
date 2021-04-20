#!/bin/bash


# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it

#----------------------------------------------------------------------------------------
# https://www.jamf.com/jamf-nation/discussions/24675/install-update-vlc
#----------------------------------------------------------------------------------------

# Run it with no arguments. 
# 
# Use as script in Jamf JSS.


# Change History:
# 2021/04/19:	Creation.
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
alias hdiutil=/usr/bin/hdiutil
alias sleep=/bin/sleep
alias perl=/usr/bin/perl
alias tail=/usr/bin/tail

set -x 

# script to update vlc
find /Volumes -type d -name "*vlc*" -maxdepth 1 -exec hdiutil detach {} \;
find /Volumes -type d -name "*VLC*" -maxdepth 1 -exec hdiutil detach {} \;

if [[ -e "/tmp/vlc.dmg" ]]; then
    rm "/tmp/vlc.dmg"
fi

#	Alternate Mirror:
# 	/usr/bin/curl --location -s https://plug-mirror.rcac.purdue.edu/vlc/vlc/last/macosx/ | perl -pe 's/.*(vlc-.*dmg).*./$1/' | grep "vlc-" | tail -n1
# https://mirror.rasanegar.com/videolan/vlc/last/macosx/
# https://get.videolan.org/vlc/${appVersion}/macosx/vlc-3.0.12-intel64.dmg

# /usr/bin/curl --location --silent  https://www.videolan.org/vlc/download-macosx.html | grep --after-context=2 "<span id='downloadVersion'>"
# <span id="downloadVersion">
# 3.0.12</span>

            
# download and mount VLC
appName=`/usr/bin/curl --location --silent https://plug-mirror.rcac.purdue.edu/vlc/vlc/last/macosx/ | perl -pe 's/.*(vlc-.*dmg).*./$1/' | grep "vlc-" | tail -n1`
appURL="https://plug-mirror.rcac.purdue.edu/vlc/vlc/last/macosx/$appName"
/usr/bin/curl --location --output "/tmp/vlc.dmg" "$appURL" 
hdiutil attach "/tmp/vlc.dmg" -nobrowse -quiet -noautoopen
sleep 3


# Install VLC
appVol=`find /Volumes -type d -name "*vlc*" -maxdepth 1`
if [[ $appVol == "" ]]; then
	appVol=`find /Volumes -type d -name "*VLC*" -maxdepth 1`
fi

if [[ $appVol == "" ]]; then
	echo "Error: VLC appVol not found."
	exit 1
fi

if [[ -e /Applications/VLC.app ]]; then
	killall VLC
	sleep 3
	rm -rf /Applications/VLC.app
fi

ditto -rsrc "$appVol/VLC.app" "/Applications/VLC.app"
chown -R root:wheel "/Applications/VLC.app"
chmod -R 755 "/Applications/VLC.app"
sleep 3
hdiutil detach "$appVol" -quiet
sleep 3
rm "/tmp/vlc.dmg"
sleep 1
# /usr/bin/open "/Applications/VLC.app" &

exit
