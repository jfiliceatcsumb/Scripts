#!/bin/zsh --no-rcs

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it


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

# https://www.virtualbox.org/manual/UserManual.html#vboxmanage-extpack

# VBoxManage extpack install [--replace] [--accept-license=sha256] <tarball>
# 
# Installs a new extension pack on the system. This command will fail if an older version of the same extension pack is already installed. The --replace option can be used to uninstall any old package before the new one is installed.
# 
# --replace
# Uninstall existing extension pack version.
# 
# --accept-license=sha256
# Accept the license text with the given SHA-256 hash value.
# 
# VBoxManage will display the SHA-256 value when performing a manual installation. The hash can of course be calculated by looking inside the extension pack and using sha256sum or similar on the license file.
# tar  --extract ./Oracle_VM_VirtualBox_Extension_Pack-*.vbox-extpack
# shasum --algorithm 256 ./Oracle_VM_VirtualBox_Extension_Pack-*.vbox-extpack/ExtPack-license.txt
# 
# tarball
# The file containing the extension pack to be installed.


# Change History:
# 2022/03/29:	Creation.
#

SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTDIR=`/usr/bin/dirname "$0"`

pathToScript=$0
pathToPackage=$1
targetLocation=$2
targetVolume=$3


alias VBoxManage="/usr/local/bin/VboxManage"
accept_license_sha256="${1}"
vbox-extpack-path=""

# Example:
# /bin/ls -FlOah "${SCRIPTDIR}"

set -x

VBoxManage list extpacks

VBoxManage extpack install --replace --accept-license=${accept_license_sha256} "${SCRIPTDIR}"/*.vbox-extpack

VBoxManage extpack cleanup

VBoxManage list extpacks
