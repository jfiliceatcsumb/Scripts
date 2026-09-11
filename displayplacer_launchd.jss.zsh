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
# 4:
# 5: 



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

shift 3
# Shift off the $1 $2 $3 parameters passed by the JSS so that parameter 4 is now $1


echo "pathToScript=$pathToScript"
echo "mountPoint=$mountPoint"
echo "computerName=$computerName"
echo "userName=$userName"

### Production path:
# MARK: Set file paths
readonly LaunchDaemonDomain="edu.csumb.it.displayplacer"
readonly LaunchDaemonLabel="${LaunchDaemonDomain}.daemon"
readonly PathToLaunchDaemon="/Library/LaunchDaemons/${LaunchDaemonLabel}.plist"
readonly PathToLaunchAgent="/Library/LaunchAgents/${LaunchDaemonDomain}.agent.plist"
readonly LaunchScript="/Library/Scripts/${LaunchDaemonDomain}.zsh"
readonly DISPLAYPLACER="/usr/local/bin/displayplacer"

# MARK: FUNCTIONS
write_launchd_script() {
    local script_path="$1"

    /bin/mkdir -p "$(/usr/bin/dirname "${script_path}")"
    /bin/cat > "${script_path}" <<EOF
#!/bin/zsh --no-rcs

DISPLAYPLACER=${(qq)DISPLAYPLACER}


echo "[\$(date)] Starting script..."

if command -v "\${DISPLAYPLACER}" &>/dev/null; then
    echo "\${DISPLAYPLACER} is installed and can be run."
else
    echo "[\$(date)] Error: \${DISPLAYPLACER} is not installed." >&2
    exit 1
fi
"${DISPLAYPLACER}" "${(qq)args_to_write[@]}"

displayplacerStatus=\$?

if [[ \${displayplacerStatus} -ne 0 ]]; then
    exit \${displayplacerStatus}
fi


echo "[\$(date)] Script completed."

EOF
    /usr/sbin/chown -fv 0:0 "${script_path}"
    /bin/chmod -fv 755 "${script_path}"
}

write_launchd_program_arguments() {
    local plist_path="$1"
		local LaunchLabel=$(/usr/bin/basename ${plist_path} .plist)
    [[ -f  "${plist_path}" ]] && /usr/bin/defaults delete "${plist_path}"
    /usr/bin/defaults write "${plist_path}" 'ProgramArguments' -array "${LaunchScript}"
		/usr/bin/defaults write "${plist_path}" 'Label' -string "${LaunchLabel}"
		/usr/bin/defaults write "${plist_path}" 'StandardOutPath' -string "/private/var/log/${LaunchLabel}_stdout.log"
		/usr/bin/defaults write "${plist_path}" 'StandardErrorPath' -string "/private/var/log/${LaunchLabel}_stderr.log"
		/usr/bin/defaults write "${plist_path}" 'KeepAlive' -bool false
		/usr/bin/defaults write "${plist_path}" 'RunAtLoad' -bool true
 
}

set_launchd_plist_privs_quarantine() {
    local plist_path="$1"
		# Set file ownership and privileges
		/usr/sbin/chown -fv 0:0 "${plist_path}"
		/bin/chmod -fv 644 "${plist_path}"
		/usr/sbin/chown -fv 0:0 "${plist_path}"
		/bin/chmod -fv 644 "${plist_path}"
		
		# Remove quarantine extended attributes
		/usr/bin/xattr -d com.apple.quarantine "${plist_path}"
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

# Slice from the 1st argument up to the 6th
# $@[4,-1] is shorthand for index 4 through the last element
# This captures $1, $2, $3, $4, $5, and $6 (if they exist)
# Filter out empty arguments from the slice [1,6]
# The (@) flag ensures we treat the result as an array even if empty
# Using "${args_to_write[@]}" ensures that if any argument contains a space, it is preserved as a single item in the defaults array

# Filter out empty elements AND slice the first 6
# - "${(@)@:#}" filters out empty/null strings
# - [1,6] slices the resulting list to the first six elements
args_to_write=( "${(@)${@:#}[1,6]}" )


# MARK: Validation Logic


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

# Warn if we are truncating
if [[ ${#args_to_write} -gt 6 ]]; then
    echo "Warning: More than 6 arguments provided. Only the first 6 will be used."
fi

# MARK: MAIN
echo "Script parameters are valid. Proceeding..."

# MARK: Unload
/bin/launchctl bootout loginwindow "${PathToLaunchAgent}" 2>/dev/null
/bin/launchctl bootout system "${PathToLaunchDaemon}" 2>/dev/null

# MARK: Delete LaunchAgent
# No longer using a LaunchAgent, so delete any if they exist
echo "Deleting old LaunchAgent plist file ${PathToLaunchAgent}..."
[[ -f  "${PathToLaunchAgent}" ]] &&  /bin/rm -v "/Library/LaunchAgents/${LaunchDaemonDomain}".*.plist

# MARK: write_launchd_script
write_launchd_script "${LaunchScript}"

# MARK: Create LaunchDaemon
echo "Creating LaunchDaemon plist file ${PathToLaunchDaemon}..."
write_launchd_program_arguments "${PathToLaunchDaemon}"
/usr/bin/defaults write "${PathToLaunchDaemon}" 'LimitLoadToSessionType' -array "Aqua" "LoginWindow"

# Enable tracing without trace output
# { set -x; } 2>/dev/null

# MARK: Set file ownership, privileges, remove quarantine
set_launchd_plist_privs_quarantine "${PathToLaunchDaemon}"

# MARK: Check launchd plist syntax
check_plist "${PathToLaunchDaemon}"

echo "Printing ${PathToLaunchDaemon}..."
/usr/libexec/PlistBuddy -x -c 'Print' "${PathToLaunchDaemon}"
echo ""

# MARK: BOOSTRAPS
/bin/launchctl bootstrap system "${PathToLaunchDaemon}" 2>&1
/bin/launchctl enable system/${LaunchDaemonLabel} 2>&1
/bin/launchctl kickstart -kp system/${LaunchDaemonLabel} 2>&1

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