#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Run it with no arguments. 
# 
# Use as script in Jamf JSS.


# https://support.sophos.com/support/s/article/KB-000033340?language=en_US#Removal-via-the-Terminal---v9.2+-installation-managed-by-Sophos-Central
# https://community.sophos.com/intercept-x-endpoint/big-sur-eap/f/recommended-reads/124391/how-to-remove-system-extensions


/usr/bin/dscl . -delete /Users/_Sophos
# cd /Library/Preferences
# rm -r com.sophos.*
/Library/Application\ Support/Sophos/saas/Installer.app/Contents/MacOS/tools/InstallationDeployer --force_remove
rm -rf /Library/Application\ Support/Sophos/ 
rm -fR /Library/SophosCBR
rm -f /Library/LaunchDaemons/com.sophos.sophoscbr.plist
rm -fR /Library/Sophos\ Anti-Virus/
rm -fR /Library/Sophos\ Live\ Query/
rm -fR /Library/Caches/com.sophos.*
rm -fR /Library/Preferences/com.sophos.*

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