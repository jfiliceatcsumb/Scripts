#!/bin/zsh --no-rcs

# https://community.jamf.com/t5/jamf-pro/packaging-maya-2025/m-p/320737/highlight/true#M277340

### Install Autodesk Apps and Licenses
### AutoCAD, Maya & MudBox (2025)

### 2025.07.19 -JonW @jonw https://macadmins.slack.com/team/U0B32NX5E


### Silently installs apps and licenses - no user interaction required
### Uses stock DMG's from Autodesk - no pkg hacking or repacking required!
### Works at loginwindow for multi-user lab/classroom deployment
### Tested on both 2024 & 2025 app versions (macOS 13 & 14) AutoCAD, Maya & MudBox
### A complete uninstall of previous versions is recommended but may not be necessary, ymmv
### Script could use some error checking, logging and fine tuning ... will get that on a slower day



### Ensure stock Autodesk install DMG's are set to CACHE (not INSTALL) via Jamf policy
### Update script variables in each of the 'app blocks' below
###   - fyi check PIT (app config file) paths every year!  Will need to perform a temporary manual installation to determine if they change or not.
###   - fyi more info on license options: /Library/Application\ Support/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper register --help

##############################################################################################
### Jamf Pro script parameters
# 
# Parameter 4 
# lic_method 
lic_method="${4}"
#    --lic_method value, --lm value       [O] new license method. Should be one of (case insensitive): USER, STANDALONE, NETWORK or empty "" to reset LGS

# Parameter 5
networkLicenseServer="${5}"
#    --lic_servers value, --ls value      [O] list of comma-separated network license server addresses or empty "" to reset. For example: @127.0.0.1,@192.168.1.1,@9.0.9.0

# Parameter 6
lic_server_type="${6}"
#    --lic_server_type value, --lt value  [O] network license server type. Should be one of (case insensitive): SINGLE, REDUNDANT, DISTRIBUTED or empty "" to reset LGS. WARNING! For empty value lic_servers will be reset as well

# Parameter 7
# e.g. ProductVersionYear="2025"
ProductVersionYear="${7}"

# Parameter 8
# productMinorVersion 
# e.g. productVersion=".0.0.F" 
### note, ProductVersion may differ!
productVersion="${8}"

# Parameter 9
# e.g ProductKey="657Q1" 
### note, ProductKey may differ!
ProductKey="${9}"

# Parameter 10
ProductSerialNumber="${10}"

# Parameter 11
# full path to install dmg in /tmp
# dmg=/private/tmp/Autodesk_Maya_2025_3_ML_MacOS.dmg 
dmg="${11}"



Volume=/Volumes/Install\ Maya\ */  ### attached dmg volume
Setup=/Volumes/Install\ Maya\ 2025/Install\ Maya\ 2025.app/Contents/Helper/setup.app/Contents/MacOS/Setup ### full path of setup app
ConfigFile=/Library/Application\ Support/Autodesk/ADLM/PIT/2025/MayaConfig.pit ### full path of installed config file - used by license function


### !!! Important !!! 
### !!! 2025 Silent install patch info - aka ODIS update !!!
### https://www.autodesk.com/support/technical/article/caas/sfdcarticles/sfdcarticles/The-application-with-bundle-ID-com-autodesk-install-is-running-setugid-which-is-not-allowed-Exiting.html

###   I had to tweak the ODIS patcher... It sort of defeats the purpose if the patcher itself doesn't work silently! C'mon Autodesk!
###   (at least as of 2024.07.19) tweaks:
### - the /Volumes/Darwin/ path in the article is wrong!  For me it's loading as: /Volumes/Macintosh\ HD\ 1/
### - this thing will throw Apple quarantine issues - resolving with xattr (i.e. just ignore the article instructions!)
### - the article makes no mention of the patch .sh script flag --mode unattended !!!  
###   I found it by digging around in the patch files!  But hey, at least it's there right?  It's always something isn't it!? 


##############################################################################################
### Function
cleanupPrePost ()
{
###########################################################################
### Ensure dmg volumes are detached

/usr/bin/hdiutil detach /Volumes/Autodesk_ODIS_Update_Contents > /dev/null 2>&1
/usr/bin/hdiutil detach /Volumes/Darwin* > /dev/null 2>&1
/usr/bin/hdiutil detach /Volumes/Install\ Maya\ */ > /dev/null 2>&1
/usr/bin/hdiutil detach /Volumes/Install\ Mudbox\ */ > /dev/null 2>&1




###########################################################################
### Clean up installers - optional, /private/tmp should auto purge on reboot
/bin/rm -rf /private/tmp/Autodesk* > /dev/null 2>&1
/bin/rm -rf /private/tmp/Darwin* > /dev/null 2>&1


}

##############################################################################################
### Function
installApp ()
{
	if [[ -e "${dmg}" ]]; then
		### Mount dmg, install silently & unmount
		echo "installing: ${dmg}"
		/usr/bin/hdiutil attach -nobrowse "${dmg}"
		"${Setup}" --silent
		/usr/bin/hdiutil detach "${Volume}"
	else
		echo "cannot locate dmg for: ${dmg}"
		echo "skipping install attempt"
	fi
}



##############################################################################################
### Function
applyLicense ()
{
	if [[ -e "${ConfigFile}" ]]; then
		### Apply License
		### details: /Library/Application\ Support/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper register --help
		/Library/Application\ Support/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper register --pk "${ProductKey}" --pv "${ProductVersionYear}${productVersion}" --cf "${ConfigFile}" --lm "${lic_method}" --ls "${networkLicenseServer}"
	else
		echo "license attempt failed, for product: ${ProductKey}"
		echo ".pit config file could not be located"
	fi	
}



##############################################################################################
### Function
silentInstallPatchODIS ()
{
	### See notes above!!
	### Tweaks as of 2025.07.19 - be aware Autodesk could change this at any time!
	
	### This is the ODIS Update dmg
	if [[ -e /private/tmp/Darwin.dmg ]]; then
		/usr/bin/hdiutil attach -nobrowse /private/tmp/Darwin.dmg -mountpoint /Volumes/Autodesk_ODIS_Update_Contents/
	elif [[ $(ls /private/tmp/Autodesk_ODIS_Update*.dmg 2>/dev/null | /usr/bin/wc -l) -gt 0  ]]; then
		/usr/bin/hdiutil attach -nobrowse /private/tmp/Autodesk_ODIS_Update*.dmg -mountpoint /Volumes/Autodesk_ODIS_Update_Contents/
	fi
	### Let's move contents out of DMG to a tmp dir
	/bin/mkdir -p /tmp/Autodesk_ODIS_Update_Contents
	/bin/cp -R /Volumes/Autodesk_ODIS_Update_Contents/* /tmp/Autodesk_ODIS_Update_Contents
	
	### Detach volume
	/usr/bin/hdiutil detach /Volumes/Autodesk_ODIS_Update_Contents
	
	### fix quarantine issues - probably just need 2nd command, but let's go wild
	/usr/bin/xattr -rd com.apple.quarantine /tmp/Autodesk_ODIS_Update_Contents
	/usr/bin/xattr -rc /tmp/Autodesk_ODIS_Update_Contents
	
	### run patch script - note, found ref to the --mode unattended flag buried in one of the supporting files, not in article?!?
	/tmp/Autodesk_ODIS_Update_Contents/AdODIS-installer.app/Contents/MacOS/installbuilder.sh --mode unattended
}




##############################################################################################
##############################################################################################

### Begin script

##############################################################################################
##############################################################################################

# set -x

cleanupPrePost

#############################################################
### Move cached DMG's from Jamf staging area to /private/tmp/

if [[ $(ls /Library/Application\ Support/JAMF/Waiting\ Room/Autodesk*.dmg 2>/dev/null | /usr/bin/wc -l) -gt 0 ]]; then
	mv -fv /Library/Application\ Support/JAMF/Waiting\ Room/Autodesk*.dmg /private/tmp
	mv -fv /Library/Application\ Support/JAMF/Waiting\ Room/Autodesk*.dmg.cache.xml /private/tmp
fi 
if [[ $(ls /Library/Application\ Support/JAMF/Waiting\ Room/Darwin*.dmg 2>/dev/null | /usr/bin/wc -l) -gt 0 ]]; then
	mv -fv /Library/Application\ Support/JAMF/Waiting\ Room/Darwin*.dmg /private/tmp
	mv -fv /Library/Application\ Support/JAMF/Waiting\ Room/Darwin*.dmg.cache.xml /private/tmp
fi


############################################
### Apply ODIS update - aka Silent install patch
silentInstallPatchODIS



##############################
### AutoCAD - install & license
# networkLicenseServer="lichen.csumb.edu"
# ProductKey="777Q1" ### note, ProductKey may differ!
# productVersion=".0.0.F" ### note, ProductVersion may differ!
# ProductVersionYear="2025"
# dmg=/private/tmp/Autodesk_AutoCAD_2025_macOS.dmg ### full path to install dmg in /tmp
# Volume=/Volumes/Installer ### attached dmg volume
# Setup=/Volumes/Installer/Install\ Autodesk\ AutoCAD\ 2025\ for\ Mac.app/Contents/Helper/Setup.app/Contents/MacOS/Setup ### full path of setup app
# ConfigFile=/Library/Application\ Support/Autodesk/ADLM/.config/ProductInformation.pit ### full path of installed config file - used by license function
# installApp
# applyLicense
# 

##############################
### Maya - install & license
# https://www.autodesk.com/support/download-install/admins/account-deploy/deploy-autocad-for-mac
# https://www.autodesk.com/support/technical/article/caas/sfdcarticles/sfdcarticles/Use-Installer-Helper.html


installApp
applyLicense
/usr/bin/hdiutil detach "${Volume}" > /dev/null 2>&1




##############################
### Mudbox - install & license
# networkLicenseServer="your.license.server.com"
# ProductKey="498Q1" ### note, ProductKey may differ!
# productVersion=".0.0.F" ### note, ProductVersion may differ!
# ProductVersionYear="2025"
# dmg=/private/tmp/Autodesk_Mudbox_2025_macOS.dmg ### full path to install dmg in /tmp
# Volume=/Volumes/Install\ Mudbox\ */ ### attached dmg volume
# Setup=/Volumes/Install\ Mudbox\ 2025/Install\ Mudbox\ 2025.app/Contents/Helper/setup.app/Contents/MacOS/Setup ### full path of setup app
# ConfigFile=/Library/Application\ Support/Autodesk/ADLM/PIT/2025/MudboxConfig.pit ### full path of installed config file - used by license function
# installApp
# applyLicense



###########################################################################
### Verify license details for all apps - optional, but nice to see in logs
/Library/Application\ Support/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper list

cleanupPrePost

echo "-------------------------"
echo "Autodesk install complete"
echo "-------------------------"
