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


# Red Giant 2025.4.1
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
#                                              Default: unattended
#                                              Allowed: osx text unattended
# 
#  --debugtrace <debugtrace>                   Debug filename
#                                              Default: 
# 
#  --installer-language <installer-language>   Language selection
#                                              Default: en
#                                              Allowed: sq ar es_AR az eu pt_BR bg ca hr cs da nl en et fi fr de el he hu id it ja kk ko lv lt no fa pl pt ro ru sr zh_CN sk sl es sv th zh_TW tr tk uk va vi cy
# 
#  --errortrace <errortrace>                   Error trace filename
#                                              Default: 
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

/bin/ls -FlOah "${SCRIPTPATH}"
# Run script found in the application bundle included alongside this postinstall script.
"${SCRIPTPATH}"/*.app/Contents/Scripts/install.sh --version --mode unattended --unattendedmodeui minimal

exit 0
