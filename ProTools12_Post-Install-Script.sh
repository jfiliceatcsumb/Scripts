#!/bin/bash

# Forked from https://github.com/moofit/scripts/blob/master/Pro%20Tools%2012/ProTools12_Post-Install-Script.sh

alias chown="/usr/sbin/chown"
alias chmod="/bin/chmod"
alias rm="/bin/rm"
alias cp="/bin/cp"
alias mkdir="/bin/mkdir"


# Copy the com.avid.bsd.ShoeTool Helper Tool
PHT_SHOETOOL="/Library/PrivilegedHelperTools/com.avid.bsd.shoetoolv120"

if [[ -e "/Applications/Pro Tools.app/Contents/Library/LaunchServices/com.avid.bsd.shoetoolv120" ]]; then
	/bin/cp -f "/Applications/Pro Tools.app/Contents/Library/LaunchServices/com.avid.bsd.shoetoolv120" $PHT_SHOETOOL
fi
if [[ -e "$PHT_SHOETOOL" ]]; then
	/usr/sbin/chown root:wheel $PHT_SHOETOOL
	/bin/chmod 544 $PHT_SHOETOOL
fi

# Create the Launch Deamon Plist for com.avid.bsd.ShoeTool
PLIST="/Library/LaunchDaemons/com.avid.bsd.shoetoolv120.plist"
FULL_PATH="/Library/PrivilegedHelperTools/com.avid.bsd.shoetoolv120"
 
if [[ -e $PLIST ]]; then
	rm $PLIST # Make sure we are idempotent
fi
 
/usr/libexec/PlistBuddy -c "Add Label string" $PLIST
/usr/libexec/PlistBuddy -c "Set Label com.avid.bsd.shoetoolv120" $PLIST
 
/usr/libexec/PlistBuddy -c "Add MachServices dict" $PLIST
/usr/libexec/PlistBuddy -c "Add MachServices:com.avid.bsd.shoetoolv120 bool" $PLIST
/usr/libexec/PlistBuddy -c "Set MachServices:com.avid.bsd.shoetoolv120 true" $PLIST
 
/usr/libexec/PlistBuddy -c "Add ProgramArguments array" $PLIST
/usr/libexec/PlistBuddy -c "Add ProgramArguments:0 string" $PLIST
/usr/libexec/PlistBuddy -c "Set ProgramArguments:0 $FULL_PATH" $PLIST
 
/bin/launchctl load $PLIST

mkdir -p "/Library/Application Support/Avid/Audio/Plug-Ins"
mkdir -p "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)"

chmod a+w "/Library/Application Support/Avid/Audio/Plug-Ins"
chmod a+w "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)"

mkdir /Users/Shared/Pro\ Tools
mkdir /Users/Shared/AvidVideoEngine

chown -R root:wheel /Users/Shared/Pro\ Tools
chmod -R a+rw /Users/Shared/Pro\ Tools
chown -R root:wheel /Users/Shared/AvidVideoEngine
chmod -R a+rw /Users/Shared/AvidVideoEngine

# Get rid of old workspace
if [[ -e /Users/Shared/Pro\ Tools/Workspace.wksp ]]; then
	rm -rf /Users/Shared/Pro\ Tools/Workspace.wksp
fi

exit 0