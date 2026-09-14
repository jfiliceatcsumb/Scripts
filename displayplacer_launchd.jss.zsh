#!/bin/zsh --no-rcs

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it
# 
# This script requires /usr/local/bin/displayplacer version 1.4.0 or newer.
#
# 
# Run by Jamf Pro.
# 
# PARAMETERS:
# 4-9:displayplacer arguments



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

SCRIPTNAME=$(/usr/bin/basename "$0")
SCRIPTDIR=$(/usr/bin/dirname "$0")

# Jamf JSS Parameters 1 through 3 are predefined as mount point, computer name, and username

pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3

if (( $# >= 3 )); then
		# Shift off the $1 $2 $3 parameters passed by the JSS so that parameter 4 is now $1
    shift 3
fi


echo "pathToScript=$pathToScript"
echo "mountPoint=$mountPoint"
echo "computerName=$computerName"
echo "userName=$userName"

# Installation requires root privileges.
if (( EUID != 0 )); then
    echo "Error: Run this script as root, through Jamf or sudo." >&2
    exit 1
fi

### Production path:
# MARK: Set file paths
readonly LaunchDaemonDomain="edu.csumb.it.displayplacer"
readonly LaunchDaemonLabel="${LaunchDaemonDomain}.daemon"
readonly LaunchAgentLabel="${LaunchDaemonDomain}.agent"
readonly PathToLaunchDaemon="/Library/LaunchDaemons/${LaunchDaemonLabel}.plist"
readonly PathToLaunchAgent="/Library/LaunchAgents/${LaunchAgentLabel}.plist"
readonly LaunchScript="/Library/Scripts/${LaunchDaemonDomain}.zsh"
readonly DISPLAYPLACER="/usr/local/bin/displayplacer"

# MARK: FUNCTIONS
write_launchd_script() {
    local script_path="$1"

    if ! /bin/mkdir -p "$(/usr/bin/dirname "${script_path}")"; then
        echo "Error: Could not create parent directory for ${script_path}." >&2
        exit 1
    fi
    if ! /bin/cat > "${script_path}" <<EOF
#!/bin/zsh --no-rcs

DISPLAYPLACER=${(qq)DISPLAYPLACER}

# Use the executing account's home directory for logs.
log_dir="\${HOME}/Library/Logs/edu.csumb.it.displayplacer"

if /bin/mkdir -p "\${log_dir}" && [[ -w "\${log_dir}" ]]; then
    exec >> "\${log_dir}/displayplacer.log" 2>&1
else
    echo "Warning: Cannot create log directory: \${log_dir}" >&2
fi

echo "[\$(date)] Starting script..."

if command -v "\${DISPLAYPLACER}" &>/dev/null; then
    echo "\${DISPLAYPLACER} is installed and can be run."
else
    echo "[\$(date)] Error: \${DISPLAYPLACER} is not installed." >&2
    exit 1
fi
"\${DISPLAYPLACER}" ${(j: :)${(@qq)args_to_write}}

displayplacerStatus=\$?

if [[ \${displayplacerStatus} -ne 0 ]]; then
    exit \${displayplacerStatus}
fi


echo "[\$(date)] Script completed."

EOF
    then
        echo "Error: Could not write generated script: ${script_path}" >&2
        exit 1
    fi
    if ! /bin/zsh -f -n "${script_path}"; then
        echo "Error: Generated script failed syntax validation: ${script_path}" >&2
        exit 1
    fi
    if ! /usr/sbin/chown -fv 0:0 "${script_path}"; then
        echo "Error: Could not set ownership: ${script_path}" >&2
        exit 1
    fi

    if ! /bin/chmod -fv 755 "${script_path}"; then
        echo "Error: Could not set executable permissions: ${script_path}" >&2
        exit 1
    fi
}

write_launchd_program_arguments() {
    local plist_path="$1"
    local LaunchLabel="${plist_path:t:r}"
# ${plist_path:t:r} is zsh’s built-in equivalent of extracting the filename and removing its .plist extension.
    if [[ -f "${plist_path}" ]]; then
        if ! /usr/bin/defaults delete "${plist_path}"; then
            echo "Error: Could not clear existing plist: ${plist_path}" >&2
            exit 1
        fi
    fi

    if ! {
        /usr/bin/defaults write "${plist_path}" ProgramArguments -array "${LaunchScript}" &&
        /usr/bin/defaults write "${plist_path}" Label -string "${LaunchLabel}" &&
        /usr/bin/defaults write "${plist_path}" KeepAlive -bool false &&
        /usr/bin/defaults write "${plist_path}" RunAtLoad -bool true &&
        /usr/bin/defaults write "${plist_path}" LimitLoadToSessionType -array "Aqua" "LoginWindow"
    }; then
        echo "Error: Could not write launchd plist: ${plist_path}" >&2
        exit 1
    fi
}

set_launchd_plist_privs() {
    local plist_path="$1"
    # Set file ownership and permissions
    if ! /usr/sbin/chown -fv 0:0 "${plist_path}"; then
        echo "Error: Could not set plist ownership: ${plist_path}" >&2
        exit 1
    fi

    if ! /bin/chmod -fv 644 "${plist_path}"; then
        echo "Error: Could not set plist permissions: ${plist_path}" >&2
        exit 1
    fi
    
}

check_plist() {
# 		Check plist files for syntax errors
	local plist_path="$1"
	/usr/bin/plutil -lint "${plist_path}"
	if [[ $? -ne 0 ]]; then
		echo "ERROR: ${plist_path} syntax check failed" >&2
		echo "Try printing the plist..."
		/usr/bin/plutil -p "${plist_path}"		
		exit 1
	else
		echo "Printing the plist..."
		/usr/bin/plutil -p "${plist_path}"
	fi
}


# MARK: Input Values

# Collect all nonempty arguments, preserving spaces within each argument.
# Apply the six-argument limit after validation below.
args_to_write=( "${(@)@:#}" )

# MARK: Validation Logic

# Validate executable file

if command -v "$DISPLAYPLACER" &>/dev/null; then
    echo "$DISPLAYPLACER is installed and can be run."
else
    echo "Error: $DISPLAYPLACER is not installed." >&2
    exit 1
fi


non_null_count=${#args_to_write}

echo "Arguments passed: $@"
echo "Total arguments passed: ${non_null_count}"

# Ensure minimum requirement is met
if [[ ${#args_to_write} -lt 1 ]]; then
    echo "Error: Minimum 1 arguments required." >&2
    exit 1
fi

# Warn before truncating to the first six nonempty arguments
if [[ ${#args_to_write} -gt 6 ]]; then
    echo "Warning: More than 6 arguments provided. Only the first 6 will be used."
    args_to_write=( "${(@)args_to_write[1,6]}" )
fi

# MARK: MAIN
echo "Script parameters are valid. Proceeding..."

# MARK: Unload existing jobs
for service_target in \
    "loginwindow/${LaunchAgentLabel}" \
    "system/${LaunchDaemonLabel}"
do
    if /bin/launchctl print "${service_target}" >/dev/null 2>&1; then
        if ! /bin/launchctl bootout "${service_target}"; then
            echo "Error: Could not unload ${service_target}." >&2
            exit 1
        fi
    fi
done

# MARK: Delete old LaunchDaemon
if [[ -f "${PathToLaunchDaemon}" ]]; then
    echo "Deleting old LaunchDaemon plist file ${PathToLaunchDaemon}..."
    if ! /bin/rm -v "${PathToLaunchDaemon}"; then
        echo "Error: Could not delete ${PathToLaunchDaemon}." >&2
        exit 1
    fi
fi

# MARK: write_launchd_script
write_launchd_script "${LaunchScript}"

# MARK: Create LaunchAgent
echo "Creating LaunchAgent plist file ${PathToLaunchAgent}..."
write_launchd_program_arguments "${PathToLaunchAgent}"

# Enable tracing without trace output
# { set -x; } 2>/dev/null

# MARK: Set file ownership and permissions
set_launchd_plist_privs "${PathToLaunchAgent}"

# MARK: Check launchd plist syntax
check_plist "${PathToLaunchAgent}"

echo "Printing ${PathToLaunchAgent}..."
/usr/libexec/PlistBuddy -x -c 'Print' "${PathToLaunchAgent}"
echo ""

# MARK: Load and start LaunchAgent
# Load only into an existing LoginWindow domain.
if /bin/launchctl print loginwindow >/dev/null 2>&1; then
    if ! /bin/launchctl bootstrap loginwindow "${PathToLaunchAgent}"; then
        echo "Error: Could not load ${LaunchAgentLabel} into LoginWindow." >&2
        exit 1
    fi
else
    echo "LoginWindow domain unavailable; deferring loading until a future session."
fi

# Disable tracing without trace output
# { set +x; } 2>/dev/null


echo "***End $SCRIPTNAME script***"

exit 0

# MARK: DOCUMENTATION AND REFERENCES 
# 
# displayplacer
# Usage:
#     Show current screen info and possible resolutions: displayplacer list
# 
#     Apply screen config (hz & color_depth are optional): displayplacer "id:<screenId> res:<width>x<height> hz:<num> color_depth:<num> scaling:<on/off> origin:(<x>,<y>) degree:<0/90/180/270>"
# 
#     Apply screen config using mode: displayplacer "id:<screenId> mode:<modeNum> origin:(<x>,<y>) degree:<0/90/180/270>"
# 
#     Apply screen config with mirrored screens: displayplacer "id:<mainScreenId>+<1stMirrorScreenId>+<2ndMirrorScreenId> res:<width>x<height> scaling:<on/off> origin:(<x>,<y>) degree:<0/90/180/270>"
# 
#     Silence errors per-screen using quiet: displayplacer "id:<screenId> mode:<modeNum> origin:(<x>,<y>) degree:0 quiet:true"
# 
#     Disable a screen: displayplacer "id:<screenId> enabled:false"
# 
# Instructions:
#     1. Manually set rotations 1st*, resolutions 2nd, and arrangement 3rd. For extra resolutions and rotations read 'Notes' below.
#         - Open System Preferences -> Displays
#         - Choose desired screen rotations (use displayplacer for rotating internal MacBook screen).
#         - Choose desired resolutions (use displayplacer for extra resolutions).
#         - Drag the white bar to your desired primary screen.
#         - Arrange screens as desired and/or enable mirroring. To enable partial mirroring hold the alt/option key and drag a display on top of another.
#     2. Use `displayplacer list` to print your current layout's args, so you can create profiles for scripting/hotkeys with Automator, BetterTouchTool, etc.
# 
# ScreenIds Switching:
#     Unfortunately, macOS sometimes changes the persistent screenIds when there are race conditions from external screens waking up in non-determinisic order. If none of the screenId options below work for your setup, please search around in the GitHub Issues for conversation regarding this. Many people have written shell scripts to work around this issue.
# 
#     You can mix and match screenId types across your setup.
#     - Persistent screenIds usually stay the same. They are recommended for most use cases.
#     - Contextual screenIds change when switching GPUs or when cables switch ports. If you notice persistent screenIds switching around, try using the contextual screenIds.
#     - Serial screenIds are tied to your display hardware. If the serial screenIds are unique for all of your monitors, use these.
# 
# Notes:
#     - *`displayplacer list` and system prefs only show resolutions for the screen's current rotation.
#     - Use an extra resolution shown in `displayplacer list` by executing `displayplacer "id:<screenId> mode:<modeNum>"`. Some of the resolutions listed do not work. If you select one, displayplacer will default to another working resolution.
#     - Rotate your internal MacBook screen by executing `displayplacer "id:<screenId> degree:<0/90/180/270>"`
#     - If you disable a screen, you may need to unplug/replug it to bring it back. However, on some setups, you can re-enable it with `displayplacer "id:<screenId> enabled:true"`
#     - The screen set to origin (0,0) will be set as the primary screen (white bar in system prefs).
#     - The first screenId in a mirroring set will be the 'Optimize for' screen in the system prefs. You can only choose resolutions for the 'Optimize for' screen. If there is a mirroring resolution you need but cannot find, try making a different screenId the first of the set.
#     - hz and color_depth are optional. If left out, the highest hz and then the highest color_depth will be auto applied.
#     - screenId is optional if there is only one screen. Rule of thumb is that displayplacer is expecting the entire profile config per screen though, so this may be buggy.
# 
# Backward Compatability:
#     `displayplacer list` output changed slightly in v1.4.0. If this broke your scripts, use `displayplacer list --v1.3.0`.
# 
# Feedback:
#     Please create a GitHub Issue for any feedback, feature requests, bugs, Homebrew issues, etc. Happy to accept pull requests too! https://github.com/jakehilborn/displayplacer