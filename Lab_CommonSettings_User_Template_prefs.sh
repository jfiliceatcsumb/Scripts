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

if [ $macOSversionMajor -gt 10 ] || [ $macOSversionMajor -eq 10 -a $macOSversionMinor -ge 15 ]; then
	echo "10.15 and newer"
	USER_TEMPL='/Library/User Template/Non_localized'
else
	echo "older than 10.15"
	USER_TEMPL='/System/Library/User Template/Non_localized'
fi

echo "USER_TEMPL=$USER_TEMPL"

mkdir -pv -m 755 "${USER_TEMPL}/Library/Preferences"

################
# Audacity
# [August 23, 2021] Prompts startup window.
# https://manual.audacityteam.org/man/preferences.html
# 

Audacity_cfg="${USER_TEMPL}/Library/Application Support/Audacity/audacity.cfg"
mkdir -pv -m 755 "$(/usr/bin/dirname $Audacity_cfg)"

touch "${Audacity_cfg}"

cat << EOF_AUDACITY_CFG >> "${Audacity_cfg}"
[GUI]
ShowSplashScreen=0
[Update]
DefaultUpdatesChecking=0
UpdateNoticeShown=1
EOF_AUDACITY_CFG

################
# 
# Fetch
# [August 17, 2021] Update notice when launched.
# com.fetchsoftworks.Fetch.plist
# 	<key>AutoCheckForUpdates</key>
# 	<false/>
defaults write "${USER_TEMPL}/Library/Preferences/com.fetchsoftworks.Fetch.plist" AutoCheckForUpdates -bool FALSE


################
# 
# Camtasia 2022
# [August 23, 2021] Prompts permissions checklist at launch. 
# 		Expected & preferred behavior.
# HasRequestedPermissions2022 -bool TRUE

################
# 
# Snagit 2022
# [August 23, 2021] Prompts permissions checklist at launch.
# 		Expected & preferred behavior.
# [August 23, 2021] Prompts Snagit Tutorial window at startup.
# tutorialAssetsShown -bool true
defaults write "${USER_TEMPL}/Library/Preferences/com.TechSmith.Snagit2022.plist" tutorialAssetsShown -bool true

################
# 
# VLC
# [August 23, 2021] Prompts at launch to check for album art and metadata (metadata network access)
defaults write "${USER_TEMPL}/Library/Preferences/org.videolan.vlc.plist" SUEnableAutomaticChecks -bool false
mkdir -pv -m 755 "${USER_TEMPL}/Library/Preferences/org.videolan.vlc"


touch "${USER_TEMPL}/Library/Preferences/org.videolan.vlc/vlcrc"
cat << EOF_VLCRC >> "${USER_TEMPL}/Library/Preferences/org.videolan.vlc/vlcrc"
###
###  vlc 3.0.17.3
###

###
### lines beginning with a '#' character are comments
###

# Allow metadata network access (boolean)
metadata-network-access=1

EOF_VLCRC

################
# 
# NVivo 20

# 	<key>appSettingUserInitials</key>
# 	<string></string>
# 
# 	<key>appSettingUserName</key>
# 	<string></string>
# 
# 	<key>appSettingShowWelcomeScreen</key>
# 	<integer>1</integer>
# 
# 	<key>SUHasLaunchedBefore</key>
# 	<true/>
# 
# 	<key>appSettingAgreedEULAVersion.20</key>
# 	<string>2.7</string>
# 
# 	<key>appSettingAnalytics</key>
# 	<integer>1</integer>

defaults write "${USER_TEMPL}/Library/Preferences/com.qsrinternational.NVivo-20.plist" 'SUHasLaunchedBefore' -bool TRUE
defaults write "${USER_TEMPL}/Library/Preferences/com.qsrinternational.NVivo-20.plist" 'appSettingAgreedEULAVersion.20' -string "2.7"
defaults write "${USER_TEMPL}/Library/Preferences/com.qsrinternational.NVivo-20.plist" 'appSettingAnalytics' -int 0


################
# Avid Sibelius 2021
# [August 23, 2021] Quick Start screen prompt at startup

################
# Musescore
# [August 23, 2021] Update notice when launched
# [August 23, 2021] Telemetry data collection prompt when launched.
# [August 23, 2021] Startup Wizard when launched.

################
#  
# Reaper
# [August 23, 2021] Update prompt after launch.

################
# WWise 2021
# [August 23, 2021] End-User License Agreement prompt when launched.
# [August 23, 2021] WWise License Manager indicates it will run in Trial mode. Trial mode restricts the SoundBank content to 200 media assets.
#  

### mac Tips 
# ~/Library/Preferences/com.apple.tipsd.plist
# TPSLastMajorVersion -string "12"
# TPSWelcomeNotificationReminderState -int 1
# TPSWelcomeNotificationViewedVersion -string "12"


##########  ##########


echo "***End $SCRIPTNAME script***"
/bin/date

exit 0
