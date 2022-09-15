#!/bin/sh

# Installing Live in a Multi-User Environment (without Sassafras)
# https://help.ableton.com/hc/en-us/articles/209073209-Installing-Live-in-a-Multi-User-Environment-without-Sassafras-

Version="11.1.6"

AbletonLiveApp="/Applications/Ableton Live 11 Suite.app"

# Set version number programmatically from app.
VersionRead=$(defaults read "$AbletonLiveApp/Contents/Info.plist" CFBundleShortVersionString | awk '{ print $1 }')

if [[ $VersionRead != "" ]]; then
	Version="$VersionRead"
fi

# 2.2.2 Create the Shared Unlock Folder
mkdir -p -m 755 "/Library/Application Support/Ableton/Live $Version/Unlock/"

# 2.2.3 Paste the Master Unlock.cfg file into the shared Unlock folder that you created in the step above.
# 
# Now, delete the Unlock folder in the default location. 
# /Users/[Username]/Library/Application Support/Ableton/Live x.x.x./Unlock/

# 2.2.4 Shared Preferences and Options.txt
# 6.2 Example Options.txt

mkdir -p -m 755 "/Library/Preferences/Ableton/Live $Version/"
touch "/Library/Preferences/Ableton/Live $Version/Options.txt"
echo "-_DisableAutoUpdates" >> "/Library/Preferences/Ableton/Live $Version/Options.txt"
echo "-DontAskForAdminRights"  >> "/Library/Preferences/Ableton/Live $Version/Options.txt"
echo "-_DisableUsageData"  >> "/Library/Preferences/Ableton/Live $Version/Options.txt"
# set permissions
chmod 644 "/Library/Preferences/Ableton/Live $Version/Options.txt"

# 3.2 Ableton Live Packs
# admin grou write access so the move operation works.
mkdir -p -m 775 "/Library/Application Support/Ableton/Factory Packs/"


# /Users/admin/Music/Ableton/
# Factory Packs
# Live Recordings
# User Library

# Move the file titled Library.cfg (found in the user preferences) to the shared preferences folder (see 2.2.5). 
# This way, information about the Ableton Live Packs you just installed will automatically be available to all users.
# /Users/alex/Library/Preferences/Ableton/Live 11.1/
# (Library.cfg, Options.txt, Log.txt)

# /Library/Preferences/Ableton/Live $Version/Library.cfg
# 				<ProjectPath Value="/Users/admin/Music/Ableton" />
# to
# 				<ProjectPath Value="/Users/%%USERNAME%%/Music/Ableton" />


# 4. Cache/ Database
echo "-DefaultsBaseFolder=/tmp/AbletonData/%%USERNAME%%/" >> "/Library/Preferences/Ableton/Live $Version/Options.txt"
echo "-DatabaseDirectory=/Users/Shared/Database/%%USERNAME%%/"  >> "/Library/Preferences/Ableton/Live $Version/Options.txt"
# set permissions
chmod 644 "/Library/Preferences/Ableton/Live $Version/Options.txt"
