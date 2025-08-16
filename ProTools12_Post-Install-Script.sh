#!/bin/bash

# Forked from https://github.com/moofit/scripts/blob/master/Pro%20Tools%2012/ProTools12_Post-Install-Script.sh

# Copy the com.avid.bsd.ShoeTool Helper Tool
PHT_SHOETOOL="/Library/PrivilegedHelperTools/com.avid.bsd.shoetoolv120"

if [[ -e "/Applications/Pro Tools.app/Contents/Library/LaunchServices/com.avid.bsd.shoetoolv120" ]]; then
	/bin/cp -f "/Applications/Pro Tools.app/Contents/Library/LaunchServices/com.avid.bsd.shoetoolv120" "${PHT_SHOETOOL}"
fi
if [[ -e "${PHT_SHOETOOL}" ]]; then
	/usr/sbin/chown root:wheel "${PHT_SHOETOOL}"
	/bin/chmod 544 "${PHT_SHOETOOL}"
fi

# Create the Launch Deamon Plist for com.avid.bsd.ShoeTool
PLIST="/Library/LaunchDaemons/com.avid.bsd.shoetoolv120.plist"
 
if [[ -e "${PLIST}" ]]; then
	/bin/launchctl bootout system "${PLIST}" 2>/dev/null
	/bin/launchctl unload -F "${PLIST}" 2>/dev/null
	/bin/rm "${PLIST}" # Make sure we are idempotent
fi

if [[ -e "${PHT_SHOETOOL}" ]]; then
	/usr/libexec/PlistBuddy -c "Add Label string" "${PLIST}"
	/usr/libexec/PlistBuddy -c "Set Label com.avid.bsd.shoetoolv120" "${PLIST}"
	 
	/usr/libexec/PlistBuddy -c "Add MachServices dict" "${PLIST}"
	/usr/libexec/PlistBuddy -c "Add MachServices:com.avid.bsd.shoetoolv120 bool" "${PLIST}"
	/usr/libexec/PlistBuddy -c "Set MachServices:com.avid.bsd.shoetoolv120 true" "${PLIST}"
	 
	/usr/libexec/PlistBuddy -c "Add ProgramArguments array" "${PLIST}"
	/usr/libexec/PlistBuddy -c "Add ProgramArguments:0 string" "${PLIST}"
	/usr/libexec/PlistBuddy -c "Set ProgramArguments:0 ${PHT_SHOETOOL}" "${PLIST}"
	 
	/bin/launchctl bootstrap system "${PLIST}" 2>/dev/null
	/bin/launchctl load "${PLIST}"  2>/dev/null
fi
/bin/mkdir -p "/Library/Application Support/Avid/Audio/Plug-Ins"
/bin/mkdir -p "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)"

/bin/chmod a+w "/Library/Application Support/Avid/Audio/Plug-Ins"
/bin/chmod a+w "/Library/Application Support/Avid/Audio/Plug-Ins (Unused)"

/bin/mkdir /Users/Shared/Pro\ Tools
/bin/mkdir /Users/Shared/AvidVideoEngine

/usr/sbin/chown -R root:wheel /Users/Shared/Pro\ Tools
/bin/chmod -R a+rw /Users/Shared/Pro\ Tools
/usr/sbin/chown -R root:wheel /Users/Shared/AvidVideoEngine
/bin/chmod -R a+rw /Users/Shared/AvidVideoEngine

# Get rid of old workspace
if [[ -e /Users/Shared/Pro\ Tools/Workspace.wksp ]]; then
	/bin/rm -rf /Users/Shared/Pro\ Tools/Workspace.wksp
fi

exit 0