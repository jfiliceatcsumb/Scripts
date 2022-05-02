#!/bin/bash

# script to determine if MS Office 2019 is installed
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
#to check for a single app version, below will identify presence of EXCEL 16.17 through 16.52:
# ^16.(1[7-9].*|[2-4][0-9].*|5[0-2].*)
#if [[ $excelversion = 16.2?* || $excelversion = 16.1[7-9]* ]];
#then echo "Excel 2019 Installed"
#else echo "Excel 2019 Not Installed"
#fi
######


#below will identify presence of any Office app version 16.17 through 16.52:
if [[ $excelversion =~ ^16.(1[7-9].*|[2-4][0-9].*|5[0-2].*) ]] || \
[[ $onenoteversion =~ ^16.(1[7-9].*|[2-4][0-9].*|5[0-2].*) ]] || \
[[ $powerpointversion =~ ^16.(1[7-9].*|[2-4][0-9].*|5[0-2].*) ]] || \
[[ $wordversion =~ ^16.(1[7-9].*|[2-4][0-9].*|5[0-2].*) ]] ;

#For JAMF EA:
then echo "<result>Office2019Installed</result>"
else echo "<result>Office2019NotInstalled</result>"
fi

exit 0