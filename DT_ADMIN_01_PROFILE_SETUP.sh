#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# http://it.csumb.edu



# Run in post by DeployStudio to set up Dock on Desktop Loadsets.
# We want these to run near the end of the workflows, just before or just after repairing permissions.
# Commands must run as root.
# 
# History
# 2015/04/16:	Creation.
# 2015/04/20:	echo "Copying User Template's Library into AdminHOME..."
# 2015/04/24:	Copying User Template/English.lproj into ${PATHtoUSER} (instead of just the Library)
# 2015/06/03:	Added TERMINAL settings.
# 2017/03/21:	Changed using more reliable $(eval echo "~admin")
# 				Changed PATHtoUSER to AdminHOME
# 2017/03/22:	Using /usr/sbin/createhomedir to create admin home.
# 				

SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

echo "***Begin $SCRIPTNAME script***"
/bin/date

#  set alias for PlistBuddy and several others so I don't have to specify full path.
# Prefix sudo path because I'm using it here for all commands.
# If I want to run a command without the alias, then specify the full path.
alias PlistBuddy="/usr/bin/sudo /usr/libexec/PlistBuddy"
alias chown="/usr/bin/sudo /usr/sbin/chown"
alias chmod="/usr/bin/sudo /bin/chmod"
alias ditto="/usr/bin/sudo /usr/bin/ditto"
alias defaults="/usr/bin/sudo defaults"
alias rm="/usr/bin/sudo /bin/rm"
alias cp="/usr/bin/sudo /bin/cp"
alias mkdir="/usr/bin/sudo /bin/mkdir"
alias mv="/usr/bin/sudo /bin/mv"
alias sudo=/usr/bin/sudo

# set -x # For debugging, show commands.



ImagePlacement='Crop'
ImageFilePath='/Library/Desktop Pictures/Solid Colors/Solid Gray Medium.png'
NewImageFilePath='/Library/Desktop Pictures/Solid Colors/Solid Gray Medium.png'
ChangePath='/Library/Desktop Pictures'
NewChangePath='/Library/Desktop Pictures'
UserFolderPaths=''
NoImage_bool='false'
BackgroundColorReal1='0.25490197539329529'
BackgroundColorReal2='0.4117647111415863'
BackgroundColorReal3='0.66666668653488159'


osXversion=`sw_vers -productVersion`
echo "osXversion=$osXversion"
# Just get the second version value after 10.
osXversion10=`echo $osXversion | awk -F. '{print $2}'`
echo "osXversion10=$osXversion10"


echo "Creating home directory for admin using /usr/sbin/createhomedir..."
/usr/sbin/createhomedir -c -l -u admin

	
# AdminHOME=$(eval echo "~admin")
# above was causing problems, so specifying path explicitly.
AdminHOME=/Users/admin

echo "Copying User Template/English.lproj into ${AdminHOME}..."
ditto -V "/Library/User Template/English.lproj" "${AdminHOME}"

########## LAUNCH SERVICES ##########
echo "Adding LSHandlers for textwrangler: plist and sh"
defaults write "${AdminHOME}/Library/Preferences/com.apple.LaunchServices.plist" LSHandlers -array-add '<dict><key>LSHandlerContentType</key> <string>com.apple.property-list</string> <key>LSHandlerRoleAll</key> <string>com.barebones.bbedit</string> </dict>'
defaults write "${AdminHOME}/Library/Preferences/com.apple.LaunchServices.plist" LSHandlers -array-add '<dict><key>LSHandlerContentType</key> <string>public.shell-script</string> <key>LSHandlerRoleAll</key> <string>com.barebones.bbedit</string> </dict>'
##########  ##########

########## FINDER ##########
defaults write "${AdminHOME}/Library/Preferences/com.apple.finder.plist" ShowPathBar -bool TRUE
defaults write "${AdminHOME}/Library/Preferences/com.apple.finder.plist" ShowPathbar -bool TRUE
defaults write "${AdminHOME}/Library/Preferences/com.apple.finder.plist" ShowStatusBar -bool TRUE
defaults write "${AdminHOME}/Library/Preferences/com.apple.finder.plist" ShowMountedServersOnDesktop -bool TRUE
defaults write "${AdminHOME}/Library/Preferences/com.apple.finder.plist" ShowHardDrivesOnDesktop -bool TRUE
defaults write "${AdminHOME}/Library/Preferences/com.apple.finder.plist" BrowserWindowRestoreAttempted -bool TRUE
defaults write "${AdminHOME}/Library/Preferences/com.apple.finder.plist" FinderSpawnWindow -bool TRUE

##########  ##########

########## DISK UTILITY ##########
echo "Enable Disk Utility Debug menu."
defaults write "${AdminHOME}/Library/Preferences/com.apple.DiskUtility.plist" DUDebugMenuEnabled -string 1
##########  ##########

########## TERMINAL ##########
defaults write "${AdminHOME}/Library/Preferences/com.apple.Terminal.plist" 'HasMigratedDefaults' -bool FALSE
defaults write "${AdminHOME}/Library/Preferences/com.apple.Terminal.plist" 'Startup Window Settings' -string "Basic"
defaults write "${AdminHOME}/Library/Preferences/com.apple.Terminal.plist" 'Default Window Settings' -string "Basic"
defaults write "${AdminHOME}/Library/Preferences/com.apple.Terminal.plist" 'Window Settings' 

PlistBuddy -c "Add :'Window Settings':Basic:TerminalType string" "/Users/admin/Library/Preferences/com.apple.Terminal.plist"
PlistBuddy -c "Set :'Window Settings':Basic:TerminalType vt100" "/Users/admin/Library/Preferences/com.apple.Terminal.plist"
PlistBuddy -c "Add :'Window Settings':Basic:CursorBlink bool" "/Users/admin/Library/Preferences/com.apple.Terminal.plist"
PlistBuddy -c "Set :'Window Settings':Basic:CursorBlink True" "/Users/admin/Library/Preferences/com.apple.Terminal.plist"
PlistBuddy -c "Add :'Window Settings':Basic:CursorType integer" "/Users/admin/Library/Preferences/com.apple.Terminal.plist"
PlistBuddy -c "Set :'Window Settings':Basic:CursorType 2" "/Users/admin/Library/Preferences/com.apple.Terminal.plist"
PlistBuddy -c "Add :'Window Settings':Basic:type string" "/Users/admin/Library/Preferences/com.apple.Terminal.plist"
PlistBuddy -c "Set :'Window Settings':Basic:type 'Window Settings'" "/Users/admin/Library/Preferences/com.apple.Terminal.plist"

PlistBuddy -c "Print " "/Users/admin/Library/Preferences/com.apple.Terminal.plist"
##########  ##########


########## DESKTOP BACKGROUND ##########
echo "Setting desktop background picture to ${ImageFilePath}..."
sudo defaults write "${AdminHOME}/Library/Preferences/com.apple.desktop.plist" Background -dict "default" "<dict> <key>BackgroundColor</key> <array> <real>${BackgroundColorReal1}</real> <real>${BackgroundColorReal2}</real> <real>${BackgroundColorReal3}</real> </array> <key>Change</key> <string>Never</string> <key>ChangePath</key> <string>${ChangePath}</string> <key>ChangeTime</key> <real>1800</real> <key>DSKDesktopPrefPane</key> <dict> <key>UserFolderPaths</key> <array> ${UserFolderPaths} </array> </dict> <key>DrawBackgroundColor</key> <true/> <key>ImageFilePath</key> <string>${ImageFilePath}</string> <key>NewChangePath</key> <string>${NewChangePath}</string> <key>NewImageFilePath</key> <string>${NewImageFilePath}</string> <key>NoImage</key> <${NoImage_bool}/> <key>Placement</key> <string>${ImagePlacement}</string> <key>Random</key> <false/> </dict>"

echo "Checking com.apple.desktop.plist with plutil..."
sudo /usr/bin/plutil "${AdminHOME}/Library/Preferences/com.apple.desktop.plist"
echo "Displaying com.apple.desktop.plist in XML..."
sudo /usr/bin/plutil -convert xml1 -o - "${AdminHOME}/Library/Preferences/com.apple.desktop.plist"

# Delete the desktoppicture.db to force the plist to be used.
sudo /bin/rm -fv "${AdminHOME}/Library/Application Support/Dock/desktoppicture.db"
##########  ##########

chown -fR admin:staff "${AdminHOME}"


echo "***End $SCRIPTNAME script***"
/bin/date

exit 0

