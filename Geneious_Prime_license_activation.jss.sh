#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script requires Geneious Prime (version 2021.1 and later )to be installed at /Applications/Geneious Prime.app.
# 
# 
# Use as script in Jamf JSS.


# Change History:
# 2024/01/26:	Creation.
#

SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTDIR=`/usr/bin/dirname "$0"`

# #####
# Set hard code static variables here or pass as script parameters.

LICENSE_KEY=''
USER_EMAIL=''

# #####


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
# set -x

# Example:
# /bin/ls -FlOah "${SCRIPTDIR}"

# https://manual.geneious.com/en/latest/22-AdvancedAdmin.html#geneiousproperties-file

# geneious.properties file

# Any preferences which can be set within Geneious Prime can also be set
# from the geneious.properties file which can be found in the Geneious
# Prime installation directory. On MacOS this file is located in Geneious
# Prime.app/Contents/Resources/app (Prime 2021.1 and later) or
# Geneious.app/Contents/Java (Prime 2021.0 and earlier). The file should
# be copied to either /Users/(username)/Library/Application
# Support/Geneious/geneious.properties (to set properties for a single
# user account) or /Library/Application
# Support/Geneious/geneious.properties (to set properties for all users of
# a computer)


# Personal or Group licenses
# 
# Open the geneious.properties file in a text editor and scroll down to
# ##provide a flexnet-local license key (except trial). Remove the #
# next to license-key= and add your license key.
# 
# Floating licenses
# 
# Scroll down to ##license server settings, and change
# override-property-flexnet_server.host and
# override-property-flexnet_server.port to the settings you require.
# Remove the # at the start of these lines for the setting to be used.
# This setting cannot be used to configure Sassafras KeyServer licenses.


# Copy the geneious.properties to the 
mkdir -v -p -m 755 "/Library/Application Support/Geneious/"
cp "/Applications/Geneious Prime.app/Contents/Resources/app/geneious.properties"  "/Library/Application Support/Geneious/geneious.properties"
/usr/bin/sed -i -e 's/#license-key=/license-key=${LICENSE_KEY}/g' "/Library/Application Support/Geneious/geneious.properties"


## disable checking for updates, both automatic and manual (admin can uncomment this when user's machine should not allow updates from the Internet)
#enable-check-internet-for-new-versions=false

/usr/bin/sed -i -e 's/#enable-check-internet-for-new-versions/enable-check-internet-for-new-versions/g' "/Library/Application Support/Geneious/geneious.properties"


chmod 644 "/Library/Application Support/Geneious/geneious.properties"
chown 0:0 -FR "/Library/Application Support/Geneious/"

defaults write "/Library/Preferences/com.biomatters.utilities.plist" 'userEmail' -string "${USER_EMAIL}"

# <key>userEmail</key>
# <string>software@csumb.edu</string>


exit 0

