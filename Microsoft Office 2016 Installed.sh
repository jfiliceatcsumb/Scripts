#!/bin/bash

# script to determine if MS Office 2016 is installed
# https://www.jamf.com/jamf-nation/discussions/31041/microsoft-office-2019-extension-attribute

if [[ -e /Applications/Microsoft\ Excel.app/Contents/Info.plist ]]; then
	excelversion=$(defaults read /Applications/Microsoft\ Excel.app/Contents/Info.plist CFBundleVersion)
fi
if [[ -e /Applications/Microsoft\ OneNote.app/Contents/Info.plist ]]; then
	onenoteversion=$(defaults read /Applications/Microsoft\ OneNote.app/Contents/Info.plist CFBundleVersion)
fi
if [[ -e /Applications/Microsoft\ Outlook.app/Contents/Info.plist ]]; then
	outlookversion=$(defaults read /Applications/Microsoft\ Outlook.app/Contents/Info.plist CFBundleVersion)
fi
if [[ -e /Applications/Microsoft\ PowerPoint.app/Contents/Info.plist ]]; then
	powerpointversion=$(defaults read /Applications/Microsoft\ PowerPoint.app/Contents/Info.plist CFBundleVersion)
fi
if [[ -e /Applications/Microsoft\ Word.app/Contents/Info.plist ]]; then
	wordversion=$(defaults read /Applications/Microsoft\ Word.app/Contents/Info.plist CFBundleVersion)
fi


######
#TESTING AREA
#echo "Excel version is $excelversion"
#echo "OneNote version is $onenoteversion"
#echo "Outlook version is $outlookversion"
#echo "PowerPoint version is $powerpointversion"
#echo "Word version is $wordversion"
#
#to check for a single app version, below will identify presence of EXCEL 15 through 16.16, including 16.0-9.x
# if [[ ^15.*|^16.([0-9]\..*|1[0-6].*) ]];
#if [[ $excelversion = 15.* || $excelversion = 16.[1-9].* || $excelversion = 16.1[0-6].* ]];
#then echo "Excel 2016 Installed"
#else echo "Excel 2016 Not Installed"
#fi
######


#below will identify presence of any Office app version 15 through 16.16:
if [[ $excelversion =~ ^15.*|^16.([0-9]\..*|1[0-6].*) ]] || \
[[ $onenoteversion =~ ^15.*|^16.([0-9]\..*|1[0-6].*) ]] || \
[[ $powerpointversion =~ ^15.*|^16.([0-9]\..*|1[0-6].*) ]] || \
[[ $wordversion =~ ^15.*|^16.([0-9]\..*|1[0-6].*) ]] ;

#For JAMF EA:
then echo "<result>Office2016Installed</result>"
else echo "<result>Office2016NotInstalled</result>"
fi

exit 0