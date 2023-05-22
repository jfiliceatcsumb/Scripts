#!/bin/sh

# Location of macOS Build plist for comparison
# Subsitute your org name for anyOrg, or place in another location
buildPlist="/usr/local/anyOrg/macOSBuild.plist"

# Get the local os build version
# Using build version accounts for supplimental updates as well as dot updates and os upgrades
localOS=$( /usr/bin/sw_vers | awk '/BuildVersion/{print $2}' )

# If the macOS Buld plist key does not exist, create it and write the local os into it
if ! /usr/libexec/PlistBuddy -c 'print "macOSBuild"' $buildPlist &> /dev/null; then
	echo "macOS Build plist does not exist. Creating now..."
	defaults write $buildPlist macOSBuild $localOS
else
	echo "macOS Build plist already exists. Skipping creation..."
fi

# Get the os from the macOS build plist now that we have ensured it exists
plistOS=$( defaults read $buildPlist macOSBuild )

# If the local OS does not match the plist OS do some maintainance
if [[ $localOS != $plistOS ]]; then
	# Check for Jamf Connect Login status and re-enable if needed
	if [[ ! $( /usr/local/bin/authchanger -print | grep JamfConnectLogin ) ]]; then
		# If JCL is disabled, re-enable it with a policy (scope carefully)
		/usr/local/bin/jamf policy -event enable-jamfconnectlogin
	else
		echo "Jamf Connect Login is enabled on this device. Nothing to do here..."
	fi
	
	# Update inventory
	/usr/local/bin/jamf recon
	
	# Update the local plist file for next time
	defaults write $buildPlist macOSBuild $localOS
else
	echo "macOS was not updated. Nothing to do here."
fi