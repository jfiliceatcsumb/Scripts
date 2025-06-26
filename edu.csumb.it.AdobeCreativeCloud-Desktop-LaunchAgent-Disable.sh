#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# http://it.csumb.edu



# This script requires superuser privileges.
# Run it with no arguments. 
# 

# Script to prevent auto launch of Adobe Creative Cloud application by disabling
#  /Library/LaunchAgents/com.adobe.AdobeCreativeCloud.plist Launch Agent.
# 
# History:
# 2015/03/11:	Creation

# 



SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

/bin/echo "***Begin $SCRIPTNAME script***"
/bin/date

# set alias for PlistBuddy and several others so I don't have to specify full path.
# Prefix sudo path because I'm using it here for all commands.
# If I want to run a command without the alias, then specify the full path.
alias PlistBuddy="/usr/bin/sudo /usr/libexec/PlistBuddy"
alias chown="/usr/bin/sudo /usr/sbin/chown"
alias chmod="/usr/bin/sudo /bin/chmod"
alias ditto="/usr/bin/sudo /usr/bin/ditto"
alias defaults="/usr/bin/sudo /usr/bin/defaults"
alias rm="/usr/bin/sudo /bin/rm"
alias cp="/usr/bin/sudo /bin/cp"
alias mkdir="/usr/bin/sudo /bin/mkdir"
alias sudo=/usr/bin/sudo

echo "Script to prevent auto launch of Adobe Creative Cloud application by disabling /Library/LaunchAgents/com.adobe.AdobeCreativeCloud.plist Launch Agent."
defaults write /Library/LaunchAgents/com.adobe.AdobeCreativeCloud.plist 'Disabled' -bool true
# Be sure to set ownership and permissions on the plist just in case.
chown -f 0:0 /Library/LaunchAgents/com.adobe.AdobeCreativeCloud.plist
chmod -f 644 /Library/LaunchAgents/com.adobe.AdobeCreativeCloud.plist

/bin/echo "***End $SCRIPTNAME script***"
/bin/date
exit 0

# Original contents of /Library/LaunchAgents/com.adobe.AdobeCreativeCloud.plist:
# 
# <?xml version="1.0" encoding="UTF-8"?>
# <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
# <plist version="1.0">
# <dict>
# 	<key>Label</key>
# 	<string>com.adobe.AdobeCreativeCloud</string>
# 	<key>Program</key>
# 	<string>/Applications/Utilities/Adobe Creative Cloud/ACC/Creative Cloud.app/Contents/MacOS/Creative Cloud</string>
# 	<key>ProgramArguments</key>
# 	<array>
# 		<string>/Applications/Utilities/Adobe Creative Cloud/ACC/Creative Cloud.app/Contents/MacOS/Creative Cloud</string>
# 		<string>--showwindow=false</string>
# 		<string>--onOSstartup=true</string>
# 	</array>
# 	<key>RunAtLoad</key>
# 	<true/>
# </dict>
# </plist>
