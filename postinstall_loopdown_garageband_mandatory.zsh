#!/bin/zsh --no-rcs
## postinstall

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script requires .
# Run it with no arguments. 
# 
# For best results, copy it to the Mac and run it as a post-flight task in DeployStudio 
# or postinstall script in a PKG installer.


# Change History:
# 2022/MM/DD:	Creation.
#

SCRIPTNAME=$(/usr/bin/basename "$0")
SCRIPTDIR=$(/usr/bin/dirname "$0")

pathToScript=$0
pathToPackage=$1
targetLocation=$2
targetVolume=$3


# Example:
/bin/ls -FlOah "${SCRIPTDIR}"
"${SCRIPTDIR}"/loopdown-1.0.20250919 --discover-plists
"${SCRIPTDIR}"/loopdown-1.0.20250919 --apps garageband --mandatory --install

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
