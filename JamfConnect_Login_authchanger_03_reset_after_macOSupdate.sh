#!/bin/zsh --no-rcs

# Modified from
# https://gist.github.com/sgmills/0a708fa4eb857ac7bf8ba84dc2b59f90#file-re-enable-jamf-connect-login-sh
# https://mostlymac.blog/2020/12/17/enable-jcl-after-os-upgrade/

# Location of macOS Build plist for comparison
# Subsitute your org name for anyOrg, or place in another location
# ##### Modified Path #####
buildPlist="/Library/Management/edu.csumb/edu.csumb.macOSBuild.plist"

# Get the local os build version
# Using build version accounts for supplimental updates as well as dot updates and os upgrades
localOS=$( /usr/bin/sw_vers | awk '/BuildVersion/{print $2}' )

ReEnableJamfConnect() {
# Check for Jamf Connect Login status and re-enable if needed
if [[ ! $( /usr/local/bin/authchanger -print | grep JamfConnectLogin ) ]]; then
# If JCL is disabled, re-enable it with a policy (scope carefully)
	/usr/local/bin/jamf policy -event enable-jamfconnectlogin
else
	echo "Jamf Connect Login is enabled on this device. Nothing to do here..."
fi
# Update inventory
/usr/local/bin/jamf recon

}

main() {
# If the macOS Build plist key does not exist, create it and write the local os into it
if ! /usr/libexec/PlistBuddy -c 'print "macOSBuild"' ${buildPlist} &> /dev/null; then
	echo "macOS Build plist does not exist. Creating now..."
	/bin/mkdir -pm 755 $(/usr/bin/dirname "${buildPlist}")
	/usr/bin/defaults write ${buildPlist} macOSBuild ${localOS}
	/usr/sbin/chown -fR 0:0 $(/usr/bin/dirname "${buildPlist}")
	/bin/chmod -fR 755 $(/usr/bin/dirname "${buildPlist}")
	/bin/chmod -f 644 "${buildPlist}"
	ReEnableJamfConnect
else
	echo "macOS Build plist already exists. Skipping creation..."
fi

# Get the os from the macOS build plist now that we have ensured it exists
plistOS=$( /usr/bin/defaults read ${buildPlist} macOSBuild )

# If the local OS does not match the plist OS do some maintainance
if [[ ${localOS} != ${plistOS} ]]; then
	ReEnableJamfConnect
	
	# Update the local plist file for next time
	/usr/bin/defaults write ${buildPlist} macOSBuild ${localOS}
	/bin/chmod -f 644 "${buildPlist}"
else
	echo "macOS was not updated. Nothing to do here."
fi
}