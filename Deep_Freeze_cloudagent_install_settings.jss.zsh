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
# Parameter 7: plist file path
# 			examples:
# /Library/Preferences
# 				"/Library/Preferences/com.faronics.cloudagent.plist"
#
# # Jamf Waiting Room
# 				"/Library/Application Support/JAMF/Waiting Room/com.faronics.cloudagent.plist"
# 
# Jamf Downloads
# 				"/Library/Application Support/JAMF/Downloads/com.faronics.cloudagent.plist"
# 
# Use as script in Jamf JSS.


# Change History:
# 2025/05/29:	Creation.
# 2025/08/06:   Added improved error handling, directory creation, and logging
#

SCRIPTNAME=$(/usr/bin/basename "$0")
SCRIPTDIR=$(/usr/bin/dirname "$0")

# # Set up logging
# readonly LOGFILE="/var/log/jamf_deepfreeze_config.log"

# Logging function
log() {
    local timestamp
    timestamp=$(/bin/date '+%Y-%m-%d %H:%M:%S')
    echo "${timestamp}: $1"
#     echo "${timestamp}: $1" >> "${LOGFILE}"
}

# Error handling function
error_exit() {
    log "ERROR: $1"
    exit 1
}

# Jamf JSS Parameters 1 through 3 are predefined as mount point, computer name, and username
pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3

shift 3
# Shift off the $1 $2 $3 parameters passed by the JSS so that parameter 4 is now $1

log "Script started"
log "pathToScript=$pathToScript"
log "mountPoint=$mountPoint"
log "computerName=$computerName"
log "userName=$userName"


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
readonly configFile="${4}"

readonly DIR_PERMS=755
readonly FILE_PERMS=644

# Validate required parameters
if [[ -z "${ServerUrl}" ]]; then
    error_exit "ServerUrl parameter is missing"
fi

if [[ -z "${FileID}" ]]; then
    error_exit "FileID parameter is missing"
fi

if [[ -z "${OrganizationID}" ]]; then
    error_exit "OrganizationID parameter is missing"
fi

if [[ -z "${configFile}" ]]; then
    error_exit "Config file path parameter is missing"
fi

# Validate ServerUrl format (basic check for http/https)
if [[ ! "${ServerUrl}" =~ ^https?:// ]]; then
    error_exit "Invalid ServerUrl format. Must start with http:// or https://"
fi

write_cloudagent_plist() {
	local ServerUrl=${1}
	local FileID=${2}
	local OrganizationID=${3}
	local configFile=${4}
	
    # Create directory if it doesn't exist
    local configDir
    configDir=$(/usr/bin/dirname "${configFile}")
    if [[ ! -d "${configDir}" ]]; then
        log "Creating directory: ${configDir}"
        /bin/mkdir -p "${configDir}" || error_exit "Failed to create directory ${configDir}"
        /bin/chmod $DIR_PERMS "${configDir}" || error_exit "Failed to set directory permissions"
    fi
    
    
	# if file exists, Removes all default information
    if [[ -e "${configFile}" ]]; then
        log "Removing existing plist settings"
        /usr/bin/defaults delete "${configFile}" || log "Warning: Failed to delete existing settings"
	fi
    
    log "Writing new plist settings"
	# Write plist file
    /usr/bin/defaults write "${configFile}" ServerUrl "${ServerUrl}" || error_exit "Failed to write ServerUrl"
    /usr/bin/defaults write "${configFile}" FileID "${FileID}" || error_exit "Failed to write FileID"
    /usr/bin/defaults write "${configFile}" OrganizationID "${OrganizationID}" || error_exit "Failed to write OrganizationID"
    
    log "Setting file permissions"
    /bin/chmod $FILE_PERMS "${configFile}" || error_exit "Failed to set file permissions"
    
	# Check the property list files for syntax errors
    log "Validating plist file"
	ls -la "${configFile}"
  if ! /usr/bin/plutil "${configFile}"; then
     error_exit "Plist validation failed"
  fi
	# debugging: print plist file
	# /usr/bin/plutil -p "${configFile}"
	
    log "Successfully wrote and validated plist file"
	return 0

}

# Execute main function
write_cloudagent_plist "${ServerUrl}" "${FileID}" "${OrganizationID}" "${configFile}"

log "Script completed successfully"
exit 0