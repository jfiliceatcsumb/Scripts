#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script requires Camtasia 2023 to already be installed
# Run in Jamf Pro policy *After*
# 
# Installs Camtasia 2023 default Library into the User Template. 

# Change History:
# 2023/08/01:	Creation.
#

SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTDIR=`/usr/bin/dirname "$0"`

# Jamf JSS Parameters 1 through 3 are predefined as mount point, computer name, and username

pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3

shift 3
# Shift off the $1 $2 $3 parameters passed by the JSS so that parameter 4 is now $1

echo "pathToScript=$pathToScript"
echo "mountPoint=$mountPoint"
echo "computerName=$computerName"
echo "userName=$userName"

# set alias for PlistBuddy and several others so I don't have to specify full path.
# Prefix sudo path because I'm using it here for all commands.
# If I want to run a command without the alias, then specify the full path.
alias PlistBuddy="/usr/libexec/PlistBuddy"
alias chown="/usr/sbin/chown"
alias chmod="/bin/chmod"
alias ditto="/usr/bin/ditto"
alias defaults="/usr/bin/defaults"
alias rm="/bin/rm"
alias cp="/bin/cp"
alias mkdir="/bin/mkdir"
alias sudo=/usr/bin/sudo

# ##### Debugging flags #####
# debug bash script by enabling verbose “-v” option
# set -v
# debug bash script using noexec (Test for syntaxt errors)
# set -n
# identify the unset variables while debugging bash script
# set -u
# debug bash script using xtrace
set -x

# Example:
# /bin/ls -FlOah "${SCRIPTDIR}"

mkdir -pv "/Library/User Template/Non_localized/Library/Application Support/TechSmith/Camtasia 2023/Library/Camtasia Libraries/Camtasia 2023"
cp -Rf "/Applications/Camtasia 2023.app/Contents/Resources/Default Libraries/Camtasia 2023/"  "/Library/User Template/Non_localized/Library/Application Support/TechSmith/Camtasia 2023/Library/Camtasia Libraries/Camtasia 2023"

if [ -e "/Applications/Camtasia 2023.app/Contents/Info.plist" ]
then
	CFBundleShortVersionString=$(defaults read "/Applications/Camtasia 2023.app/Contents/Info.plist" CFBundleShortVersionString)
	echo "$CFBundleShortVersionString" > "/Library/User Template/Non_localized/Library/Application Support/TechSmith/Camtasia 2023/Library/Camtasia Libraries/Camtasia 2023/CamtasiaVersion"
	echo "en" >> "/Library/User Template/Non_localized/Library/Application Support/TechSmith/Camtasia 2023/Library/Camtasia Libraries/Camtasia 2023/CamtasiaVersion"
	chmod -fR 644 "/Library/User Template/Non_localized/Library/Application Support/TechSmith/Camtasia 2023/Library/Camtasia Libraries/Camtasia 2023/CamtasiaVersion"
fi

chown -fR 0:0 "/Library/User Template/Non_localized/Library/Application Support/TechSmith/Camtasia 2023/Library/Camtasia Libraries/Camtasia 2023/CamtasiaVersion"

# "/Applications/Camtasia 2023.app/Contents/Resources/Default Libraries/Camtasia 2023"
# 
# 
# "$HOME/Library/Application Support/TechSmith/Camtasia 2023/Library/Camtasia Libraries/Camtasia 2023"
# 
# 
# 	<key>CFBundleShortVersionString</key>
# 	<string>2023.1.0</string>
# 
# 
# "$HOME/Library/Application Support/TechSmith/Camtasia 2023/Library/Camtasia Libraries/Camtasia 2023/CamtasiaVersion"
# 2023.1.0
# en

exit 0
