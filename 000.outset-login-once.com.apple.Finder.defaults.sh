#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it


# Script to set Finder defaults once for a new account. Part of provisioning.
# Using Outset to run this replaces the legacy method of using User Template plist files.
# This script expects to be run by outset at login, in the user context, only once.
# Run it with no arguments. 
# 


# Change History:
# 2020/10/09:	Creation.
# 2021/08/12:	Added FXPreferredViewStyle
# 				Added ShowSidebar
#

SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

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


# write prefs
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool TRUE
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool TRUE
defaults write com.apple.finder ShowMountedServersOnDesktop -bool TRUE
defaults write com.apple.finder ShowPathbar -bool TRUE
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool TRUE
defaults write com.apple.finder ShowStatusBar -bool TRUE
defaults write com.apple.finder SidebarDevicesSectionDisclosedState -bool TRUE
defaults write com.apple.finder SidebarPlacesSectionDisclosedState -bool TRUE
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder ShowSidebar -bool TRUE

# restart Finder
/usr/bin/killall -v -KILL Finder
/bin/launchctl load -F /System/Library/LaunchAgents/com.apple.Finder.plist
/bin/launchctl start com.apple.Finder

exit 0

# 
# <key>ShowExternalHardDrivesOnDesktop</key>
# <true/>
# <key>ShowHardDrivesOnDesktop</key>
# <true/>
# <key>ShowMountedServersOnDesktop</key>
# <true/>
# <key>ShowPathbar</key>
# <true/>
# <key>ShowRemovableMediaOnDesktop</key>
# <true/>
# <key>ShowStatusBar</key>
# <true/>
# <key>SidebarDevicesSectionDisclosedState</key>
# <true/>
# <key>SidebarPlacesSectionDisclosedState</key>
# <true/>
