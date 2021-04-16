#!/bin/bash

#----------------------------------------------------------------------------------------
# https://www.jamf.com/jamf-nation/discussions/24675/install-update-vlc
#----------------------------------------------------------------------------------------

# script to update vlc
find /Volumes -type d -name "*vlc*" -maxdepth 1 -exec hdiutil detach {} \;
find /Volumes -type d -name "*VLC*" -maxdepth 1 -exec hdiutil detach {} \;

if [[ -e "/tmp/vlc.dmg" ]]; then
    rm "/tmp/vlc.dmg"
fi

# download and mount VLC
appName=`curl -s http://mirror.rasanegar.com/videolan/vlc/last/macosx/ | perl -pe 's/.*(vlc-.*dmg).*./$1/' | grep "vlc-" | tail -n1`
appURL="http://mirror.rasanegar.com/videolan/vlc/last/macosx/$appName"
curl -Lo "/tmp/vlc.dmg" "$appURL" --silent
hdiutil attach "/tmp/vlc.dmg" -nobrowse -quiet -noautoopen
sleep 5


# Install VLC
appVol=`find /Volumes -type d -name "*vlc*" -maxdepth 1`
if [[ $appVol = "" ]]; then
	appVol=`find /Volumes -type d -name "*VLC*" -maxdepth 1`
fi

if [[ $appVol = "" ]]; then
	echo "Error: VLC appVol not found."
	exit 1
fi

rm -rf /Applications/VLC.app

ditto -rsrc "$appVol/VLC.app" "/Applications/VLC.app"
chown -R root:wheel "/Applications/VLC.app"
chmod -R 755 "/Applications/VLC.app"
sleep 3
hdiutil detach "$appVol" -quiet
sleep 3
rm "/tmp/vlc.dmg"
sleep 1
open "/Applications/VLC.app" &

exit 0