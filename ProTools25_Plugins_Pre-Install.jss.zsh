#!/bin/zsh --no-rcs

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it

#
# Purpose: moves and cleans up files installed in a current user directory by Pro Tools installer 
# Version: 1.0
# Tested with: Avid Pro Tools v.25.6 installer
#
# Requirements:
# - Must be run as root
# - macOS 10.15 or newer recommended
#
# ##### Debugging flags #####
# debug bash script by enabling verbose “-v” option
# set -v
# debug bash script using noexec (Test for syntaxt errors)
# set -n
# identify the unset variables while debugging bash script
# set -u
# debug bash script using xtrace
# set -x
# Enable tracing without trace output
# { set -x; } 2>/dev/null
# Disable tracing without trace output
# { set +x; } 2>/dev/null


# Script constants
readonly SCRIPT_NAME=$(/usr/bin/basename "$0")
readonly SCRIPT_DIR=$(/usr/bin/dirname "$0")
readonly TIMESTAMP=$(/bin/date +"%Y-%m-%d %H:%M:%S")
readonly IOPlatformUUID=$(/usr/sbin/ioreg -d2 -c IOPlatformExpertDevice | awk -F\" '/IOPlatformUUID/{print $(NF-1)}')

# File Structure Constants
readonly DIR_PERMS=755
readonly FILE_PERMS=644

# Function to log messages with timestamp
log_message() {
    local level=$1
    shift
    echo "${TIMESTAMP} [${level}] $*"
}

# Function to log errors
log_error() {
    log_message "ERROR" "$*" >&2
}

# Function to log info
log_info() {
    log_message "INFO" "$*"
}

# trap for cleanup
cleanup() {
    log_info "Performing cleanup..."
    # Add cleanup actions if needed
    # Delete /Users/root/ directory and files
    # Clean up after the Avid installers. We do not want a /Users/root left behind
    # If USERIDHOME was some other user, then we will just leave it behind.
		local IOPlatformUUID=$(get_UUID)
    if [[ -e "/Users/root" ]]; then
        log_info "Cleaning up /Users/root directory..."
        /bin/rm -fRx "/Users/root"
    fi
    if [[ -n ${loggedInUser} ]] && [[ -n ${IOPlatformUUID} ]] && [[ -e "/tmp/${loggedInUser}_${IOPlatformUUID}" ]]; then
        log_info "Cleaning up /tmp/${loggedInUser}_${IOPlatformUUID} directory..."
        /bin/rm -fRx "/tmp/${loggedInUser}_${IOPlatformUUID}"
    fi
}
trap 'cleanup' EXIT

# Function to check if script is running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Function to get macOS version
get_macos_version() {
    local version
    version=$(/usr/bin/sw_vers -productVersion)
    echo "$version"
}

# Function to get IOPlatformUUID 
get_UUID() {
    local UUID
    UUID=$(/usr/sbin/ioreg -d2 -c IOPlatformExpertDevice | awk -F\" '/IOPlatformUUID/{print $(NF-1)}')
    echo "$UUID"
}

# Function to determine template location based on OS version
set_user_templ() {
    local version=$1
    local major minor
    
    # Parse version string
    major=$(echo "$version" | cut -d. -f1)
    minor=$(echo "$version" | cut -d. -f2)
    
    if [[ $major -gt 10 ]] || [[ $major -eq 10 && $minor -ge 15 ]]; then
        log_info "macOS version $version detected"
        log_info "Setting User Template path: '/Library/User Template/Non_localized'"
        USER_TEMPL='/Library/User Template/Non_localized'
    else
        log_info "macOS version $version detected"
				log_info "Setting User Template path: '/System/Library/User Template/Non_localized'"
				USER_TEMPL='/System/Library/User Template/Non_localized'
    fi
}

# Function to create directory with proper permissions
create_directory() {
    local dir="${1}"
    log_info "Creating directory: ${dir}"

    if ! /bin/mkdir -pvm ${DIR_PERMS} "${dir}"; then
        log_error "Failed to create directory: ${dir}"
        return 1
    fi
}

# Function to copy files to the user template.
ditto_files() {
		local SOURCEPATH="${1}"
		local DESTINATIONPATH="${2}" 
		if [[ -e "${SOURCEPATH}" ]]; then
			log_info "Copying ${SOURCEPATH} to ${DESTINATIONPATH}"
			if ! /usr/bin/ditto --noacl --noqtn "${SOURCEPATH}" "${DESTINATIONPATH}"; then
					log_error "Failed to copy ${SOURCEPATH}"
					return 1
			fi    
		else
			log_info "Skipping source path not found: ${SOURCEPATH}"
		fi
}

# Function to move files back to their original path after copying or moving files to user template
move_files() {
		local SOURCEPATH="${1}"
		local DESTINATIONPATH="${2}" 
		local DESTINATIONDIRECTORY="$(/usr/bin/dirname "$2")"
		if [[ -e "${SOURCEPATH}" ]]; then
			log_info "Moving ${SOURCEPATH} to ${DESTINATIONPATH}"
			create_directory "${DESTINATIONDIRECTORY}"
			if ! /usr/bin/ditto --noacl --noqtn "${SOURCEPATH}" "${DESTINATIONPATH}"; then
					log_error "Failed to move ${SOURCEPATH}"
					return 1
			fi    
			if ! /bin/rm -fRx "${SOURCEPATH}"; then
					log_error "Failed to move ${SOURCEPATH}"
					return 1
			fi    
		else
			log_info "Skipping source path not found: ${SOURCEPATH}"
		fi
}

# Main execution starts here
main() {
    
	readonly IOPlatformUUID=$(get_UUID)
	
    # Check if running as root
    check_root
    
# Use similar method as the stupid Avid installer scripts to determine the userID (typically "root")
#	Determine currently loggged in user because this is what the Avid installers use to create the user directory.
	# $homedir = $ENV{'HOME'}
	# $userid = basename($homedir)
	# return $userid;

	readonly loggedInUser=$(stat -f "%Su" /dev/console 2>/dev/null) 
		if [[ "${loggedInUser}" == "root" || "${loggedInUser}" == "" ]]; then
		readonly USERIDHOME_Avid="/Users/root"
		readonly USERIDHOME_REAL="$(/usr/bin/dscl . -read /Users/root NFSHomeDirectory | awk '{print $NF}' 2>/dev/null)"
		else
		readonly USERIDHOME_Avid="/Users/${loggedInUser}"
		readonly USERIDHOME_REAL="$(/usr/bin/dscl . -read /Users/${loggedInUser} NFSHomeDirectory | awk '{print $NF}' 2>/dev/null)"
		dscl -q . -read /Users/fili4665 NFSHomeDirectory | awk '{print $NF}'
		fi

    # Get and validate macOS version
    local os_version
    os_version=$(get_macos_version)
    typeset -g USER_TEMPL
    set_user_templ "$os_version"
    log_info "User Template path: ${USER_TEMPL}"
    
# 	remove any files already in /Users/root
   cleanup 
#     
	# ##  Move files to temporary ${IOPlatformUUID} location
	move_files "${USERIDHOME_REAL}/Music/K-Devices/Presets" "/tmp/${loggedInUser}_${IOPlatformUUID}/Music/K-Devices/Presets"
	move_files "${USERIDHOME_Avid}/Library/Audio/Presets" "/tmp/${loggedInUser}_${IOPlatformUUID}/Library/Audio/Presets"
	move_files "${USERIDHOME_Avid}/Documents/Pro Tools/Plug-In Settings" "/tmp/${loggedInUser}_${IOPlatformUUID}/Documents/Pro Tools/Plug-In Settings" 
	move_files "${USERIDHOME_Avid}/Documents/Pro Tools/Track Presets" "/tmp/${loggedInUser}_${IOPlatformUUID}/Documents/Pro Tools/Track Presets"
	move_files "${USERIDHOME_Avid}/Library/Preferences/Avid/" "/tmp/${loggedInUser}_${IOPlatformUUID}/Library/Preferences/Avid/"  
	move_files "${USERIDHOME_Avid}/Library/Preferences/com.airmusictech.*.plist" "/tmp/${loggedInUser}_${IOPlatformUUID}/Library/Preferences/" 

# hide temporary ${IOPlatformUUID} location
	/usr/bin/chflags  -fhxR  hidden "/tmp/${loggedInUser}_${IOPlatformUUID}"
    
    cleanup
    
}

log_info "Starting ${SCRIPT_NAME} script"
 
# Execute main function with error handling
if ! main; then
    log_error "${SCRIPT_NAME} script failed to complete successfully"
    exit 1
fi

log_info "${SCRIPT_NAME} script completed successfully"

exit 0

# /bin/mv
# /bin/rm
# /bin/cp
# /usr/bin/ditto


