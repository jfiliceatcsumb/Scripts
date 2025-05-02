#!/bin/sh
## postinstall

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Postinstall script to run install script for Red Giant software installers.
# This script can be used with 
# Requires the Cinema4D  installer (e.g. Maxon Cinema 4D Full Installer.app) 
# included as pkg script resource so that it is the same directory as this script
# 
# https://www.maxon.net/en/downloads/cinema-4d-r25-downloads
# 
# https://support.maxon.net/hc/en-us/articles/7759018177052-How-do-I-perform-a-silent-install-of-Cinema-4D-
# https://support.maxon.net/hc/en-us/articles/4687177301788-Running-Scripted-Installers#heading-3
# https://support.maxon.net/hc/en-us/articles/4667435548700-How-do-I-enable-RLM-mode-in-Maxon-App-
# https://support.maxon.net/hc/en-us/articles/4667400822044-Setting-up-your-Client-Machines-
# https://support.maxon.net/hc/en-us/articles/4667883865756-Unified-RLM-Licensing-FAQs

# 
# <Full Installer Name>. app/Contents/MacOS/installbuilder.sh --mode unattended --unattendedmodeui none
# Or if you wish to customise the installation location:
# <Full Installer Name>.app/Contents/MacOS/installbuilder.sh –mode text
# 
# Note: Running as ‘sudo’ or root is required as the installer needs elevated permissions to run. Using this will require the user to have administrator privileges.
# 
# Maxon Cinema 4D 2024
# Usage:
# 
#  --help                                      Display the list of valid options
# 
#  --version                                   Display product information
# 
#  --unattendedmodeui <unattendedmodeui>       Unattended Mode UI
#                                              Default: minimalWithDialogs
#                                              Allowed: none minimal minimalWithDialogs
# 
#  --optionfile <optionfile>                   Installation option file
#                                              Default: 
# 
#  --debuglevel <debuglevel>                   Debug information level of verbosity
#                                              Default: 2
#                                              Allowed: 0 1 2 3 4
# 
#  --mode <mode>                               Installation mode
#                                              Default: osx
#                                              Allowed: osx text unattended
# 
#  --debugtrace <debugtrace>                   Debug filename
#                                              Default: 
# 
#  --installer-language <installer-language>   Language selection
#                                              Default: en
#                                              Allowed: sq ar es_AR az eu pt_BR bg ca hr cs da nl en et fi fr de el he hu id it ja kk ko lv lt no fa pl pt ro ru sr zh_CN sk sl es sv th zh_TW tr tk uk va vi cy
# 
#  --prefix <prefix>                           Installation Directory
#                                              Default: /Applications/Maxon Cinema 4D 2024
# 
# 

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
"${SCRIPTPATH}"/*.app/Contents/MacOS/installbuilder.sh --mode unattended --unattendedmodeui minimal

exit 0
