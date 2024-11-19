#!/bin/bash

# script to determine if MS Office 2024 is installed

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
#to check for a single app version, below will identify presence of EXCEL 16.89 through 16.99:
#if [[ $excelversion = ^16.(89.*|9[0-9].*) ]];
#if [[ $excelversion = 16.89* || $excelversion = 16.9[0-9]* ]];
#then echo "Excel 2024 Installed"
#else echo "Excel 2024 Not Installed"
#fi
######

# Office LTSC for Mac 2024 has version numbers of 16.89 or higher. Office LTSC for Mac 2021 has version numbers of 16.53 or higher.
# https://learn.microsoft.com/en-us/microsoft-365-apps/mac/overview?source=recommendations#version-numbers

#below will identify presence of any Office app version 16.89 through 16.99:
if [[ $excelversion =~ ^16.(89.*|9[0-9].*) ]] || \
[[ $onenoteversion =~ ^16.(89.*|9[0-9].*) ]] || \
[[ $powerpointversion =~ ^16.(89.*|9[0-9].*) ]] || \
[[ $wordversion =~ ^16.(89.*|9[0-9].*) ]] ;

#For JAMF EA:
then echo "<result>Office2024Installed</result>"
else echo "<result>Office2024NotInstalled</result>"
fi

exit 0