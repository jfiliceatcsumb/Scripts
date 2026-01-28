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
# 4: device type (input/output/system/all).  Defaults to output
# 5: Audio device name or UID (case insensitive grep matching)

# 
# Change History:
# 2025/12/10:	Creation.
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

# Allowed device_type values: input | output | system


# --- Validation Logic ---

# Validate executable file at /usr/local/bin/SwitchAudioSource

displayplacer="/usr/local/bin/displayplacer"

if command -v "$displayplacer" &>/dev/null; then
    echo "$displayplacer is installed and can be run."
else
    echo "Error: $displayplacer is not installed." >&2
    exit 1
fi


# Validate input 
# Temporarily set the style for case-insensitivity for 'case' comparisons


echo "Script parameters are valid. Proceeding..."

### Production path:
PathToLaunchAgent="/Library/LaunchAgents/edu.csumb.it.displayplacer_launchd.agent.plist"
PathToLaunchDaemon="/Library/LaunchDaemons/edu.csumb.it.displayplacer_launchd.daemon.plist"
# 
# # Create script.
# PathToScript="/Library/Management/edu.csumb/edu.csumb.displayplacer_launchd.zsh"
# 
# 
# cat > "${PathToScript}" <<EOF
# #!/bin/zsh --no-rcs
# /bin/date
# ${displayplacer} "${4}" "${5}" "${6}" "${7}" "${8}" "${9}"
# 
# exit 0
# EOF
# 
LaunchAgentLabel=$(/usr/bin/basename ${PathToLaunchAgent} .plist)
LaunchDaemonLabel=$(/usr/bin/basename ${PathToLaunchDaemon} .plist)

/bin/launchctl bootout loginwindow "${PathToLaunchAgent}" 2>/dev/null
/bin/launchctl bootout system "${PathToLaunchDaemon}" 2>/dev/null


# #### Create LaunchAgent ####
echo "Creating LaunchAgent plist file ${PathToLaunchAgent}..."
if [[ -f "${PathToLaunchAgent}" ]]; then
    /usr/bin/defaults delete "${PathToLaunchAgent}"
fi
# /usr/bin/defaults write "${PathToLaunchAgent}" 'ProgramArguments' -array "${PathToScript}"
/usr/bin/defaults write "${PathToLaunchAgent}" 'ProgramArguments' -array "${displayplacer}" "${4}" "${5}" "${6}" "${7}" "${8}" "${9}"
/usr/bin/defaults write "${PathToLaunchAgent}" 'Label' -string "${LaunchAgentLabel}"
/usr/bin/defaults write "${PathToLaunchAgent}" 'StandardOutPath' -string "/private/var/log/${LaunchAgentLabel}_stdout.log"
/usr/bin/defaults write "${PathToLaunchAgent}" 'StandardErrorPath' -string "/private/var/log/${LaunchAgentLabel}_stderr.log"
/usr/bin/defaults write "${PathToLaunchAgent}" 'UserName' -string "root"
/usr/bin/defaults write "${PathToLaunchAgent}" 'LimitLoadToSessionType' -array "Aqua" "LoginWindow"
/usr/bin/defaults write "${PathToLaunchAgent}" 'KeepAlive' -bool false
/usr/bin/defaults write "${PathToLaunchAgent}" 'RunAtLoad' -bool true
/usr/bin/defaults write "${PathToLaunchAgent}" 'Debug' -bool true

# #### Create LaunchDaemon ####
echo "Creating LaunchDaemon plist file ${PathToLaunchDaemon}..."

if [[ -f "${PathToLaunchDaemon}" ]]; then
    /usr/bin/defaults delete "${PathToLaunchDaemon}"
fi
# /usr/bin/defaults write "${PathToLaunchDaemon}" 'ProgramArguments' -array "${PathToScript}"
/usr/bin/defaults write "${PathToLaunchDaemon}" 'ProgramArguments' -array "${displayplacer}" "${4}" "${5}" "${6}" "${7}" "${8}" "${9}"
/usr/bin/defaults write "${PathToLaunchDaemon}" 'Label' -string "${LaunchDaemonLabel}"
/usr/bin/defaults write "${PathToLaunchDaemon}" 'StandardOutPath' -string "/private/var/log/${LaunchDaemonLabel}_stdout.log"
/usr/bin/defaults write "${PathToLaunchDaemon}" 'StandardErrorPath' -string "/private/var/log/${LaunchDaemonLabel}_stderr.log"
/usr/bin/defaults write "${PathToLaunchDaemon}" 'KeepAlive' -bool false
/usr/bin/defaults write "${PathToLaunchDaemon}" 'RunAtLoad' -bool true
/usr/bin/defaults write "${PathToLaunchDaemon}" 'Debug' -bool true


# Enable tracing without trace output
# { set -x; } 2>/dev/null

# Set file ownership and privileges

/usr/sbin/chown -fv 0:0 "${PathToLaunchAgent}" "${PathToLaunchDaemon}"
/bin/chmod -fv 644 "${PathToLaunchAgent}" "${PathToLaunchDaemon}"
# /usr/sbin/chown -fv 0:0 "${PathToScript}"
# /bin/chmod -fv 644 "${PathToScript}"

# Remove quarantine extended attributes
/usr/bin/xattr -d com.apple.quarantine "${PathToLaunchAgent}"
/usr/bin/plutil -lint "${PathToLaunchAgent}"
/usr/bin/plutil -p "${PathToLaunchAgent}"
/usr/bin/xattr -d com.apple.quarantine "${PathToLaunchDaemon}"
/usr/bin/plutil -lint "${PathToLaunchDaemon}"
/usr/bin/plutil -p "${PathToLaunchDaemon}"


/bin/launchctl enable loginwindow/${LaunchAgentLabel} 2>&1
/bin/launchctl bootstrap loginwindow "${PathToLaunchAgent}" 2>&1
/bin/launchctl enable system/${LaunchDaemonLabel} 2>&1
/bin/launchctl bootstrap system "${PathToLaunchDaemon}" 2>&1
/bin/launchctl kickstart system/${LaunchDaemonLabel} 2>&1

# Disable tracing without trace output
# { set +x; } 2>/dev/null

echo "***End $SCRIPTNAME script***"

exit 0
