#!/bin/bash

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# http://csumb.edu/it



# This script requires superuser privileges.
# Run it with no arguments. 
# 

# Script to prevent auto launch of Adobe Creative Cloud application by disabling
#  LaunchAgents:
# com.adobe.AdobeCreativeCloud.plist
# com.adobe.ccxprocess.plist
# com.adobe.GC.AGM.plist
# com.adobe.GC.Invoker-1.0.plist
# 

# 



SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

/bin/echo "***Begin $SCRIPTNAME script***"
/bin/date

# set alias for PlistBuddy and several others so I don't have to specify full path.
# Prefix sudo path because I'm using it here for all commands.
# If I want to run a command without the alias, then specify the full path.

# Jamf script to prevent Adobe Creative Cloud from autolaunching at login
# Tested on macOS 15 (Sequoia) and earlier

echo "Disabling Adobe CC LaunchAgents..."

# List of Adobe LaunchAgents to remove or disable
launchAgents=(
  "com.adobe.AdobeCreativeCloud.plist"
  "com.adobe.ccxprocess.plist"
  "com.adobe.GC.AGM.plist"
  "com.adobe.GC.Invoker-1.0.plist"
)

# Remove system-wide LaunchAgents
for agent in "${launchAgents[@]}"; do
  if [ -f "/Library/LaunchAgents/$agent" ]; then
    echo "Disabling /Library/LaunchAgents/$agent"
	/bin/launchctl bootout system "/Library/LaunchAgents/$agent"
	/usr/bin/defaults write "/Library/LaunchAgents/$agent" 'Disabled' -bool true
	# Be sure to set ownership and permissions on the plist just in case.
	/usr/sbin/chown -f 0:0 "/Library/LaunchAgents/$agent"
	/bin/chmod -f 644 "/Library/LaunchAgents/$agent"
	# Adobe CC updates will often reinstall these launch agents. 
	# To prevent this Set file immutability
	/usr/bin/chflags schg "/Library/LaunchAgents/$agent"
  fi
done



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
