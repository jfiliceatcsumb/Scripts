#!/bin/zsh --no-rcs

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script requires 3 arguments as Jamf Pro script parameters:
# 
# Parameter 4: ServerUrl
# Parameter 5: FileID=
# Parameter 6: OrganizationID

# 
# Use as script in Jamf JSS.


# Change History:
# 2025/05/29:	Creation.
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


readonly ServerUrl="${1}"
readonly FileID="${2}"
readonly OrganizationID="${3}"

readonly configFileWaitingRoom="/Library/Application Support/JAMF/Waiting Room/com.faronics.cloudagent.plist"

readonly configFileDownloads="/Library/Application Support/JAMF/Downloads/com.faronics.cloudagent.plist"

readonly configFileLibraryPrefs="/Library/Preferences/com.faronics.cloudagent.plist"

readonly DIR_PERMS=755
readonly FILE_PERMS=644

write_cloudagent_plist() {
	local configFile=${1}
	local ServerUrl=${2}
	local FileID=${3}
	local OrganizationID=${4}
	
	# if file exists, Removes all default information
	if [[ -e "${configFile}" ]];then
		/usr/bin/defaults delete "${configFile}"
	fi
	# Write plist file
	/usr/bin/defaults write "${configFile}" ServerUrl "${ServerUrl}"
	/usr/bin/defaults write "${configFile}" FileID "${FileID}"
	/usr/bin/defaults write "${configFile}" OrganizationID "${OrganizationID}"
	/bin/chmod $FILE_PERMS "${configFile}"
	# Check the property list files for syntax errors
	ls -la "${configFile}"
	/usr/bin/plutil "${configFile}"
	# debugging: print plist file
	# /usr/bin/plutil -p "${configFile}"
	
	return 0

}

# Jamf Waiting Room
# write_cloudagent_plist "${configFileWaitingRoom}" "${ServerUrl}" "${FileID}" "${OrganizationID}"

# Jamf Downloads
# write_cloudagent_plist "${configFileDownloads}" "${ServerUrl}" "${FileID}" "${OrganizationID}"

# /Library/Preferences
write_cloudagent_plist "${configFileLibraryPrefs}" "${ServerUrl}" "${FileID}" "${OrganizationID}"


exit 0

