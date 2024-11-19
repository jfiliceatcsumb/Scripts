#!/bin/bash

# script to determine if MS Office 2021 is installed
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
#to check for a single app version, below will identify presence of EXCEL 16.53 through 16.99:
#if [[ $excelversion = ^16.(5[3-9].*|[6-9][0-9].*) ]];
#if [[ $excelversion = 16.5[3-9]* || $excelversion = 16.[6-9][0-9]* ]];
#then echo "Excel 2021 Installed"
#else echo "Excel 2021 Not Installed"
#fi
######

# Office LTSC for Mac 2024 has version numbers of 16.89 or higher. Office LTSC for Mac 2021 has version numbers of 16.53 or higher.
# https://learn.microsoft.com/en-us/microsoft-365-apps/mac/overview?source=recommendations#version-numbers

#below will identify presence of any Office app version 16.53 through 16.88:
if [[ $excelversion =~ ^16.(5[3-9].*|[6-7][0-9].*|8[0-8].*) ]] || \
[[ $onenoteversion =~ ^16.(5[3-9].*|[6-7][0-9].*|8[0-8].*) ]] || \
[[ $powerpointversion =~ ^16.(5[3-9].*|[6-7][0-9].*|8[0-8].*) ]] || \
[[ $wordversion =~ ^16.(5[3-9].*|[6-7][0-9].*|8[0-8].*) ]] ;

#For JAMF EA:
then echo "<result>Office2021Installed</result>"
else echo "<result>Office2021NotInstalled</result>"
fi

exit 0