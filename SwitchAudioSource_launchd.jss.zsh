#!/bin/zsh --no-rcs

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it
# 
# This script requires /usr/local/bin/SwitchAudioSource version 1.2.2 or newer.
# Sets  audio output to script input parameter. 
# If multiple values are provided, the script will stop after setting it to the first match. 
# Run by Jamf Pro.
# 
# PARAMETERS:
# 4: device type (input|output|system|all).  Defaults to output
# 5: Audio device name or UID (case insensitive grep matching)
# 6: Mute mode (mute|unmute|toggle)


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

# MARK: Input Values

device_type="${1:-output}"
device_type="${device_type:l}" # Normalize all device_type values to lowercase
device_name_uid="${2:-builtin}"
mute_mode="${3:-}"

# MARK: Set file paths
readonly LaunchDaemonDomain="edu.csumb.it.SwitchAudioSource"
readonly LaunchDaemonLabel="${LaunchDaemonDomain}.${device_type}.daemon"
readonly LaunchAgentLabel="${LaunchDaemonDomain}.${device_type}.agent"
readonly PathToLaunchDaemon="/Library/LaunchDaemons/${LaunchDaemonLabel}.plist"
readonly PathToLaunchAgent="/Library/LaunchAgents/${LaunchAgentLabel}.plist"
readonly LaunchScript="/Library/Scripts/${LaunchDaemonDomain}.${device_type}.zsh"
readonly Switch_Audio_Source="/usr/local/bin/SwitchAudioSource"

# MARK: FUNCTIONS
write_launchd_script() {
    local script_path="$1"

    if ! /bin/mkdir -p "$(/usr/bin/dirname "${script_path}")"; then
        echo "Error: Could not create parent directory for ${script_path}." >&2
        exit 1
    fi
    if ! /bin/cat > "${script_path}" <<EOF
#!/bin/zsh --no-rcs

Switch_Audio_Source=${(qq)Switch_Audio_Source}
device_type=${(qq)device_type}
device_name_uid=${(qq)device_name_uid}
mute_mode=${(qq)mute_mode}

echo "[\$(date)] Starting script..."

if command -v "\${Switch_Audio_Source}" &>/dev/null; then
    echo "\${Switch_Audio_Source} is installed and can be run."
else
    echo "[\$(date)] Error: \${Switch_Audio_Source} is not installed." >&2
    exit 1
fi

allAudioSources=\$("\${Switch_Audio_Source}" -a -f cli -t "\${device_type}")
allAudioSourcesStatus=\$?

if [[ \${allAudioSourcesStatus} -ne 0 || -z "\${allAudioSources}" ]]; then
    echo "[\$(date)] Error: Unable to enumerate \${device_type} audio devices with \${Switch_Audio_Source}." >&2
    exit 1
fi

matchedAudioSource=\$(printf '%s\n' "\${allAudioSources}" | grep --ignore-case --max-count=1 -e "\${device_name_uid}")

if [[ -z "\${matchedAudioSource}" ]]; then
    echo "[\$(date)] Warning: Device '\${device_name_uid}' not currently available. It will be checked again the next time launchd loads this job." >&2
    exit 0
fi

selectAudioSourceName=\$(printf '%s\n' "\${matchedAudioSource}" | /usr/bin/awk -F',' '{print \$1}')
selectAudioSourceUID=\$(printf '%s\n' "\${matchedAudioSource}" | /usr/bin/awk -F',' '{print \$NF}')

if printf '%s\n' "\${selectAudioSourceName}" | grep --ignore-case --quiet -e "\${device_name_uid}"; then
    "\${Switch_Audio_Source}" -t "\${device_type}" -s "\${selectAudioSourceName}"
elif [[ -n "\${selectAudioSourceName}" ]]; then
    "\${Switch_Audio_Source}" -t "\${device_type}" -u "\${selectAudioSourceUID}"
else
    echo "[\$(date)] Error: Matched device record did not include a usable device name." >&2
    exit 1
fi
switchAudioSourceStatus=\$?

if [[ \${switchAudioSourceStatus} -ne 0 ]]; then
    exit \${switchAudioSourceStatus}
fi

if [[ -n "\${mute_mode}" ]]; then
    "\${Switch_Audio_Source}" -t "\${device_type}" -m "\${mute_mode}"
    muteStatus=\$?
    if (( muteStatus != 0 )); then
        echo "[\$(date)] Error: Could not set mute state for \${device_type}." >&2
        exit \${muteStatus}
    fi
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

# MARK: Validation Logic

# Validate executable file

if command -v "$Switch_Audio_Source" &>/dev/null; then
    echo "$Switch_Audio_Source is installed and can be run."
else
    echo "Error: $Switch_Audio_Source is not installed." >&2
    exit 1
fi


# Validate device_type using a case statement

case "${device_type}" in
    input)
        # Valid value, assign the value as lower-case. 
				# SwitchAudioSource is case-senstive
        device_type="input"
        echo "Valid device_type: $device_type"
        ;;
    output)
        # Valid value, assign the value as lower-case. 
				# SwitchAudioSource is case-senstive
        device_type="output"
        echo "Valid device_type: $device_type"
        ;;
    system)
        # Valid value, assign the value as lower-case. 
				# SwitchAudioSource is case-senstive
        device_type="system"
        echo "Valid device_type: $device_type"
        ;;
    all)
        # Valid value, assign the value as lower-case. 
				# SwitchAudioSource is case-senstive
        device_type="all"
        echo "Valid device_type: $device_type"
        ;;
    *)
        # Invalid value, print error and exit
        echo "Error: Invalid device_type value: $device_type" >&2
        echo "Allowed values are: input, output, system, all." >&2
        exit 1
        ;;
esac


if [[ -n "${mute_mode}" ]]; then
    case "${mute_mode}" in
        mute|unmute|toggle)
            echo "Valid mute_mode: $mute_mode"
            ;;
        *)
            echo "Error: Invalid mute_mode value: $mute_mode" >&2
            echo "Allowed values are: mute, unmute, toggle." >&2
            exit 1
            ;;
    esac
		if [[ "${device_type}" == "system" && -n "${mute_mode}" ]]; then
				echo "Error: Mute mode is not supported for device_type 'system'." >&2
				echo "Leave Jamf parameter 6 empty when using device_type 'system'." >&2
				exit 1
		fi
fi


# MARK: MAIN
echo "Script parameters are valid. Proceeding..."

echo 'https://github.com/deweller/switchaudio-osx'
echo "Show  current ${device_type} device, json format with labels..."
${Switch_Audio_Source} -c -f json -t ${device_type}
echo "List ${device_type} devices, cli format..."
# /usr/local/bin/SwitchAudioSource -a -f cli -t output


allAudioSources=$(${Switch_Audio_Source} -a -f cli -t ${device_type})
allAudioSourcesStatus=$?

if [[ ${allAudioSourcesStatus} -ne 0 || -z "${allAudioSources}" ]]; then
    echo "Error: Unable to enumerate ${device_type} audio devices with ${Switch_Audio_Source}." >&2
    exit 1
fi

echo "All audio sources..."
echo "${allAudioSources}"

echo "Find requested device ${device_name_uid}..."
printf '%s\n' "${allAudioSources}" | grep --ignore-case -e "${device_name_uid}"

# grep for the first source that is like the input $device_name_uid, then use awk to get the device_UID as the last item.
selectAudioSourceUID=$(printf '%s\n' "${allAudioSources}" | grep --ignore-case --max-count=1 -e "${device_name_uid}" | /usr/bin/awk -F',' '{print $NF}')

# grep for the first source that is like the input $device_name_uid, then use awk to get the device_name as the first item.
selectAudioSourceName=$(printf '%s\n' "${allAudioSources}" | grep --ignore-case --max-count=1 -e "${device_name_uid}" | /usr/bin/awk -F',' '{print $1}')

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

# Usage: 
# SwitchAudioSource [-a] [-c] [-t type] [-n] -s device_name | -i device_id | -u device_uid
# 	-a             : shows all devices
# 	-c             : shows current device
# 	-f format      : output format (cli/human/json). Defaults to human.
# 	-t type        : device type (input/output/system/all).  Defaults to output.
# 	-m mute_mode : sets the mute status (mute/unmute/toggle). (version 1.2.0+)
# 	-n             : cycles the audio device to the next one
# 	-i device_id   : sets the audio device to the given device by id
# 	-u device_uid  : sets the audio device to the given device by uid or a substring of the uid
# 	-s device_name : sets the audio device to the given device by name
# 

# If you set LimitLoadToSessionType to an array, be aware that each instance of your agent runs independently. For example, if you set up your agent to run in LoginWindow and Aqua, the system will first run an instance of your agent in the loginwindow context. When a user logs in, that instance will be terminated and a second instance will launch in the standard GUI context.
# https://developer.apple.com/library/archive/technotes/tn2083/_index.html#//apple_ref/doc/uid/DTS10003794-CH1-SUBSECTION44
# 
# <?xml version="1.0" encoding="UTF-8"?>
# <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "www.apple.com">
# <plist version="1.0">
# <dict>
#     <key>Label</key>
#     <string>com.mycompany.loginscript</string> <!-- Must match filename -->
#     <key>ProgramArguments</key>
#     <array>
#         <string>/usr/local/bin/my_login_script.sh</string>
#     </array>
#     <key>RunAtLoad</key>
#     <true/>
#     <key>KeepAlive</key>
#     <false/> <!-- Run once, not continuously -->
#     <key>LimitLoadToSessionType</key>
#     <string>LoginWindow</string> <!-- Crucial for running at login screen -->
# </dict>
# </plist>

