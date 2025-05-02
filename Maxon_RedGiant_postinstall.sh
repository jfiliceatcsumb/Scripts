#!/bin/sh
## postinstall

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Postinstall script to run install script for Red Giant software installers.
# This script can be used with 
# Requires the Red Giant installer (e.g. Red Giant Application Manager 1.2.1 Installer.app) included as pkg script resource.
# Run it with no arguments. 
# 
# https://support.maxon.net/hc/en-us/articles/4667883865756-Unified-RLM-Licensing-FAQs
# https://support.maxon.net/hc/en-us/articles/4687177301788-Running-Scripted-Installers#RunningScriptedInstaller-Mac
# https://support.maxon.net/hc/en-us/articles/4667435548700-How-do-I-enable-RLM-mode-in-Maxon-App-
# https://support.maxon.net/hc/en-us/articles/4667400822044-Setting-up-your-Client-Machines-


# Change History:
# 2021/08/25:	Creation.
#

SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

pathToScript=$0
pathToPackage=$1
targetLocation=$2
targetVolume=$3



# set alias for PlistBuddy and several others so I don't have to specify full path.
# 
alias PlistBuddy="/usr/libexec/PlistBuddy"
alias chown="/usr/sbin/chown"
alias chmod="/bin/chmod"
alias ditto="/usr/bin/ditto"
alias defaults="/usr/bin/defaults"
alias rm="/bin/rm"
alias cp="/bin/cp"
alias mkdir="/bin/mkdir"
alias sudo=/usr/bin/sudo


/bin/ls -FlOah "${SCRIPTPATH}"
# Run script found in the application bundle included alongside this postinstall script.
"${SCRIPTPATH}"/*.app/Contents/Scripts/install.sh

exit 0
