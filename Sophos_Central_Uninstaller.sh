#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Run it with no arguments. 
# 
# Use as script in Jamf JSS.

# Note: On MacOS 12.1 or higher, if the script steps fail, perform the following:
# Open Terminal and run the command sudo /usr/bin/dscl . -delete /Users/_Sophos
# https://support.sophos.com/support/s/article/KB-000033340?language=en_US#Removal-via-the-Terminal---v9.2+-installation-managed-by-Sophos-Central
# If needed:
# https://community.sophos.com/intercept-x-endpoint/big-sur-eap/f/recommended-reads/124391/how-to-remove-system-extensions

echo ""
/usr/bin/dscl . -delete /Users/_Sophos

if [[ -e /Library/Application\ Support/Sophos/saas/Installer.app/Contents/MacOS/tools/InstallationDeployer ]]; then
	/Library/Application\ Support/Sophos/saas/Installer.app/Contents/MacOS/tools/InstallationDeployer --force_remove
else
	echo "InstallationDeployer tool not found."
fi
# Manual removal:
echo "Employing manual deletions for additional cleanup..."
echo "Bootout com.sophos.sophoscbr.plist..."
/bin/launchctl bootout system /Library/LaunchDaemons/com.sophos.sophoscbr.plist
echo $?
echo "launchctl legacy command..."
/bin/launchctl unload -F /Library/LaunchDaemons/com.sophos.sophoscbr.plist
echo "Manual file deletion..."
/bin/rm -vf /Library/LaunchDaemons/com.sophos.sophoscbr.plist
/bin/rm -vrf /Library/Application\ Support/Sophos/ 
/bin/rm -vfR /Library/SophosCBR/
/bin/rm -vfR /Library/Sophos\ Anti-Virus/
/bin/rm -vfR /Library/Sophos\ Live\ Query/
/bin/rm -vfR /Library/Caches/com.sophos.*
/bin/rm -vfR /Library/Preferences/com.sophos.*


exit 0

# 
# usage: InstallationDeployer [--ui] --install [--product_name <product_name>] [--tamper_password <tamper_password>] [--features <feature_list>] [--autoUpdateProtocolVersion <AUP_version>] [--notificationId <notification_id>][--suppress_temp_cleanup]
#        InstallationDeployer --receipt [--temp_directory_name <temp_directory_name>] [--protocol_version <protocol_version_int>]
#        InstallationDeployer [--ui] --remove [--tamper_password <tamper_password>] [--notificationId <notification_id>]
#        InstallationDeployer [--ui] --force_remove [--tamper_password <tamper_password>] [--notificationId <notification_id>]
# options: 
#        --ui                     => communicate with GUI
#        --install                => install product
#        --receipt                => receipt mode
#        --remove                 => remove product mode - must be run on receipt
#        --force_remove           => force remove product mode
#        --suppress_temp_cleanup  => used by bootstrapper. Caller takes responsibility for cleanup
# arguments: 
#        product_name             => the name of the product to be installed
#        tamper_password          => tamper protection password
#        feature_list             => comma separated list of features to install
#        AUP_version              => a version number indicating semantic changes between SophosAutoUpdate and InstallationDeployer
#        temp_directory_name      => temporary directory name that is shared by installer and receipt
#        protocol_version         => installers protocol version number
#        notification_id          => the object on which the InstallationDeployer will post distributed notifications
# return codes:
#        0 => success
#        0 => The installation was successful.
#        1 => The installation failed.
#        4 => Insufficient disk space to install.
#        2 => Feature not implemented.
# notes:
#        The InstallationDeployer must be run as root when the --ui option is NOT specified.
#        Without the --ui option specified, admin authentication will be requested through the user interface.
# 