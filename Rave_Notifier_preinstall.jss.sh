#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Preinstall script to delete existing application bundle.
# For best results run preinstall script in a PKG installer.
# 
# Use as preinstall script in Jamf JSS.


# Change History:
# 2024/04/26:	Creation.
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
appBundleDefaultPath="/Applications/Rave Notifier.app"
appBundleID="com.ale-enterprise.RaveNotifier"
ProcNameToKill="Rave Notifier"


/usr/bin/killall -vq "${ProcNameToKill}"

if [[ -e "$appBundleDefaultPath" ]]; then
	/bin/rm -fR "$appBundleDefaultPath"
fi

# Save found application paths as an array of strings.
# Normally, the explicit rm command above should remove the only copy installed on most systems.
appBundleIDfound=(${(f)"$(/usr/bin/mdfind  kMDItemCFBundleIdentifier="${appBundleID}")"})
# Iterate through each element of the array to delete all found copies.
for appBundlePath in ${appBundleIDfound[@]}; do
	echo "deleting ${appBundlePath}..."
	/bin/rm -fR "${appBundlePath}"
done

exit 0

