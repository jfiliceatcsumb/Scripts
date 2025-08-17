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
{ set -x; } 2>/dev/null
# Disable tracing without trace output
# { set +x; } 2>/dev/null

# Enable strict error handling
set -e

# Script constants
readonly SCRIPT_NAME=$(/usr/bin/basename "$0")
readonly SCRIPT_DIR=$(/usr/bin/dirname "$0")
readonly TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

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
    local dir=$1
    if ! /bin/mkdir -pvm ${DIR_PERMS} "$dir"; then
        log_error "Failed to create directory: $dir"
        return 1
    fi
}

# Function to write config files
write_config_file() {
    local file=$1
    local content=$2
    
    if ! echo "$content" > "$file"; then
        log_error "Failed to write config file: $file"
        return 1
    fi
}


# Main execution starts here
main() {
    log_info "Starting DaVinci Resolve Studio default user settings configuration script"
    
    # Check if running as root
    check_root
    
# Use similar method as the stupid Avid installer scripts to determine the userID (typically "root")
#	Determine currently loggged in user because this is what the Avid installers use to create the user directory.
		loggedInUser=$(stat -f "%Su" /dev/console) 2>/dev/null
		if [[ "${loggedInUser}" == "root" || "${loggedInUser}" == "" ]]; then
			USERID="root"
		else
  	  USERID="${loggedInUser}"
		fi

    # Get and validate macOS version
    local os_version
    os_version=$(get_macos_version)
    typeset -g USER_TEMPL
    set_user_templ "$os_version"
    log_info "User Template path: ${USER_TEMPL}"
    
    
    # Create  directories
    log_info "Creating directories..."
    log_info "Creating directory: ${USER_TEMPL}/Documents/Pro Tools/Demo Sessions"
    create_directory "${USER_TEMPL}/Documents/Pro Tools/Demo Sessions" || exit 1
    
    log_info "Creating directory: ${USER_TEMPL}/Documents/Pro Tools/Demo Sketches"
    create_directory "${USER_TEMPL}/Documents/Pro Tools/Demo Sketches" || exit 1
    
#     log_info "Creating directory: ${USER_TEMPL}/Library/Preferences/Avid"
#     create_directory "${USER_TEMPL}/Library/Preferences/Avid" || exit 1
#     
    
# ## Pro Tools Installation
# /Users/$USERID/Documents/Pro Tools/Demo Sessions/
# /Users/$USERID/Documents/Pro Tools/Demo Sketches/
    
#   Copy files
		log_info "Copying /Users/${USERID}/Documents/Pro Tools/Demo Sessions/ to ${USER_TEMPL}"
		/usr/bin/ditto --noacl --noqtn "/Users/${USERID}/Documents/Pro Tools/Demo Sessions" "${USER_TEMPL}/Documents/Pro Tools/Demo Sessions"

		log_info "Copying /Users/${USERID}/Documents/Pro Tools/Demo Sketches/ to ${USER_TEMPL}"
		/usr/bin/ditto --noacl --noqtn "/Users/${USERID}/Documents/Pro Tools/Demo Sketches" "${USER_TEMPL}/Documents/Pro Tools/Demo Sketches"
    
    # Set root ownership on target directories and files
    log_info "Setting root ownership on ${USER_TEMPL}..."
    if ! /usr/sbin/chown -fR 0:0 "${USER_TEMPL}"; then
        log_error "Failed to set ownership on: $USER_TEMPL"
        return 1
    fi

    # Delete /Users/root/ directory and files
    # Clean up after the Avid installers. We do not want a /Users/root left behind
    # If USERID was some other user, then we will just leave it behind.
    if [[ -d "/Users/root" ]]; then
    	log_info "Delete /Users/root/ directory and files..."
	    /bin/rm -fRx "/Users/root"
    fi
    
}

# Execute main function with error handling
if ! main; then
    log_error "Script failed to complete successfully"
    exit 1
fi

log_info "Pro Tools post install and cleanup completed successfully"

exit 0

# ## Pro Tools Installation
# /Users/$USERID/Documents/Pro Tools/Demo Sessions/
# /Users/$USERID/Documents/Pro Tools/Demo Sketches/

# ## Other installations
# /Users/$USERID/Library/Preferences/
# /Users/$USERID/Library/Preferences/Avid/
# /Users/$USERID/Documents/Pro Tools/Track Presets/Avid/AIR Instruments Bundle/
# /Users/$USERID/Library/Preferences/com.airmusictech.*.plist


# mkdir -p "$TARGET"
# cp -Rpv "/Users/$USERID/Documents/Pro Tools/Demo Sessions/" "/Library/User Template/Non_localized/Documents/Pro Tools/Demo Sessions"

# /bin/mv
# /bin/rm
# /bin/cp
# /usr/bin/ditto


# ls -FlOahR /Users/$USERID/


