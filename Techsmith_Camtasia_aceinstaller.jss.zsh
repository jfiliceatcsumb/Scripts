#!/bin/zsh --no-rcs

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it


# Install the System Audio Component for End Users

# This script requires Camtasia to be installed already.
# This script requires one argument: AppVersionSuffix.
# Include any space and version numbers (if any) after the app name and before the .app filepath sufix.
# For example, for '/Applications/Camtasia 2023.app' 
# the argument value would be " 2023"
# For example, for '/Applications/Camtasia.app' 
# the argument value would be ""
# 
# Use as script in Jamf JSS.

# https://support.techsmith.com/hc/en-us/articles/203727638-Enterprise-Install-Guidelines-For-Camtasia-on-macOS
# key file path: /Users/Shared/TechSmith/Camtasia/LicenseKey
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
AppVersionSuffix=""
AppVersionSuffix="${1}"

cd "/Applications/Camtasia${AppVersionSuffix}.app/Contents/Resources"
"/Applications/Camtasia${AppVersionSuffix}.app/Contents/Resources/aceinstaller" install

exit 0

