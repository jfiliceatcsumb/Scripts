#!/bin/sh
## postinstall

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Copied script functions from /ZoomInstallerIT-5.6.1.560/zoomus/Scripts/postinstall.sh

# Run it with no arguments. 
# 
# For best results, copy it to the Mac and run it as a post-flight task in DeployStudio 
# or postinstall script in a PKG installer.


# Change History:
# 2021/MM/DD:	Creation.
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


# Example:
# /bin/ls -FlOah "${SCRIPTPATH}"

#########################

# Corrected syntax on ps command
function kill_coreaudiod()
{
 #    coreaudiod_pid=$(ps -ax  -o pid -o command | grep "coreaudiod"\
#     | while read each_p
#     do
#     echo "$each_p"
#     done \
#     | grep "/usr/sbin/coreaudiod" | grep --invert-match grep  | awk '{print $1}')
# 
#     if [[ $coreaudiod_pid > 0 ]]; then
#         kill -9 $coreaudiod_pid
#     fi

	coreaudiod_pid=$( ps -ax -o pid -o command | grep "/usr/sbin/coreaudiod" | grep --invert-match grep | awk '{print $1}' )
    
	for each_pid in $coreaudiod_pid
	do
		if [[ $each_pid -gt 0 ]] 
		then
# 			kill -9 $each_pid
			echo "kill -9 $each_pid"
		fi
	done

# 	killall coreaudiod
	
}

set -x

#################################
# use audio device plugin
# AudioPluginPath=/Library/Audio/Plug-Ins/HAL
# audioPluginfile="$ZOOM_PATH"/Contents/Plugins/ZoomAudioDevice.driver
echo "Load Zoom audio device driver..."
# unload device kernel if loaded
st=$(kextstat -b zoom.us.ZoomAudioDevice | grep zoom.us.ZoomAudioDevice 2>&1)
if [[ $st = *zoom.us.ZoomAudioDevice* ]] ; then
	echo "Zoom audio device is loaded: ($st) skip driver"
else
	echo "Zoom audio device is not loaded: kill coreaudiod"
	kill_coreaudiod
fi

set +x

exit 0

# Available Installer environment variables and examples, many of which are typical global variables:
# 
# PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/libexec
# TMPDIR=/private/tmp/PKInstallSandbox.7PigCx/tmp
# DSTROOT=/
# DSTVOLUME=/
# SCRIPT_NAME=preinstall
# SHARED_INSTALLER_TEMP=/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/C/PKInstallSandboxManager-shared-tmp
# SHELL=/bin/bash
# HOME=/Users/admin
# USER=admin
# LOGNAME=admin
# HOSTTYPE=x86_64
# MACHTYPE=x86_64-apple-darwin13
# UID=501
# EUID=501
# PWD=/

# All environment variables and examples:
# 
# BASH=/bin/sh
# BASH_ARGC=([0]="4")
# BASH_ARGV=([0]="/" [1]="/" [2]="/" [3]="/Users/admin/~PKG~Template copy/Package Name.pkg")
# BASH_LINENO=([0]="0")
# BASH_SOURCE=([0]="/tmp/PKInstallSandbox.7PigCx/Scripts/edu.csumb.it.package.w7sQMp/preinstall")
# BASH_VERSINFO=([0]="3" [1]="2" [2]="53" [3]="1" [4]="release" [5]="x86_64-apple-darwin13")
# BASH_VERSION='3.2.53(1)-release'
# DIRSTACK=()
# DSTROOT=/
# DSTVOLUME=/
# EUID=0
# GROUPS=()
# HOME=/Users/admin
# HOSTNAME=mb73-125.csumb.edu
# HOSTTYPE=x86_64
# IFS=' 	
# '
# INSTALLER_SECURE_TEMP=/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/C/PKInstallSandboxManager/EE19542E-784A-4515-9EDE-B97B253CA0CC.activeSandbox/54E66773-1794-4689-8224-61D26F55E01C
# INSTALLER_TEMP=/private/tmp/PKInstallSandbox.7PigCx/tmp
# INSTALL_PKG_SESSION_ID=edu.csumb.it.package
# MACHTYPE=x86_64-apple-darwin13
# OPTERR=1
# OPTIND=1
# OSTYPE=darwin13
# PACKAGE_PATH='/Users/admin/~PKG~Template copy/Package Name.pkg'
# PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/libexec
# PIPESTATUS=([0]="0")
# POSIXLY_CORRECT=y
# PPID=60372
# PS4='+ '
# PWD=/private/tmp/PKInstallSandbox.7PigCx/Scripts/edu.csumb.it.package.w7sQMp
# SCRIPT_NAME=preinstall
# SHARED_INSTALLER_TEMP=/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/C/PKInstallSandboxManager-shared-tmp
# SHELL=/bin/sh
# SHELLOPTS=braceexpand:hashall:interactive-comments:posix
# SHLVL=1
# TERM=dumb
# TMPDIR=/private/tmp/PKInstallSandbox.7PigCx/tmp
# UID=0
# USER=admin
# 
