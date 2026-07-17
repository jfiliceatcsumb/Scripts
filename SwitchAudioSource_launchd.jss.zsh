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

shift 3
# Shift off the $1 $2 $3 parameters passed by the JSS so that parameter 4 is now $1

echo "pathToScript=$pathToScript"
echo "mountPoint=$mountPoint"
echo "computerName=$computerName"
echo "userName=$userName"

# MARK: INPUT VALUES

device_type="${1:-output}"
device_name_uid="${2:-builtin}"
mute_mode="${3:-}"

# MARK: Set file paths
readonly LaunchAgentLabel="edu.csumb.it.SwitchAudioSource.${device_type}.agent"
readonly PathToLaunchAgent="/Library/LaunchAgents/${LaunchAgentLabel}.plist"
readonly LaunchDaemonLabel="edu.csumb.it.SwitchAudioSource.${device_type}.daemon"
readonly PathToLaunchDaemon="/Library/LaunchDaemons/${LaunchDaemonLabel}.plist"
readonly LaunchScript="/Library/Scripts/$(/usr/bin/basename ${LaunchDaemonLabel} .daemon).zsh"
readonly Switch_Audio_Source="/usr/local/bin/SwitchAudioSource"

# MARK: FUNCTIONS
write_launchd_script() {
    local script_path="$1"

    /bin/mkdir -p "$(/usr/bin/dirname "${script_path}")"
    /bin/cat > "${script_path}" <<EOF
#!/bin/zsh --no-rcs

Switch_Audio_Source=${Switch_Audio_Source:q}
device_type=${device_type:q}
device_name_uid=${device_name_uid:q}
mute_mode=${mute_mode:q}

if command -v "\${Switch_Audio_Source}" &>/dev/null; then
    echo "\${Switch_Audio_Source} is installed and can be run."
else
    echo "Error: \${Switch_Audio_Source} is not installed." >&2
    exit 1
fi

allAudioSources=\$("\${Switch_Audio_Source}" -a -f cli -t "\${device_type}")
allAudioSourcesStatus=\$?

if [[ \${allAudioSourcesStatus} -ne 0 || -z "\${allAudioSources}" ]]; then
    echo "Error: Unable to enumerate \${device_type} audio devices with \${Switch_Audio_Source}." >&2
    exit 1
fi

matchedAudioSource=\$(echo "\${allAudioSources}" | grep --ignore-case --max-count=1 -e "\${device_name_uid}")

if [[ -z "\${matchedAudioSource}" ]]; then
    echo "Warning: Device '\${device_name_uid}' not currently available. It will be checked again the next time launchd loads this job." >&2
    exit 0
fi

selectAudioSourceUID=\$(echo "\${matchedAudioSource}" | /usr/bin/awk -F',' '{print \$NF}')
selectAudioSourceName=\$(echo "\${matchedAudioSource}" | /usr/bin/awk -F',' '{print \$1}')

if echo "\${selectAudioSourceUID}" | grep --ignore-case --quiet -e "\${device_name_uid}"; then
    "\${Switch_Audio_Source}" -t "\${device_type}" -u "\${selectAudioSourceUID}"
elif [[ -n "\${selectAudioSourceName}" ]]; then
    "\${Switch_Audio_Source}" -t "\${device_type}" -s "\${selectAudioSourceName}"
else
    echo "Error: Matched device record did not include a usable device name." >&2
    exit 1
fi
switchAudioSourceStatus=\$?

if [[ \${switchAudioSourceStatus} -ne 0 ]]; then
    exit \${switchAudioSourceStatus}
fi

if [[ -n "\${mute_mode}" ]]; then
    "\${Switch_Audio_Source}" -m "\${mute_mode}"
fi
EOF
    /usr/sbin/chown -fv 0:0 "${script_path}"
    /bin/chmod -fv 755 "${script_path}"
}

write_launchd_program_arguments() {
    local plist_path="$1"
		local LaunchLabel=$(/usr/bin/basename ${plist_path} .plist)
    /usr/bin/defaults delete "${plist_path}"
    /usr/bin/defaults write "${plist_path}" 'ProgramArguments' -array "${LaunchScript}"
		/usr/bin/defaults write "${plist_path}" 'Label' -string "${LaunchLabel}"
		/usr/bin/defaults write "${plist_path}" 'StandardOutPath' -string "/private/var/log/${LaunchLabel}_stdout.log"
		/usr/bin/defaults write "${plist_path}" 'StandardErrorPath' -string "/private/var/log/${LaunchLabel}_stderr.log"
		/usr/bin/defaults write "${plist_path}" 'KeepAlive' -bool false
		/usr/bin/defaults write "${plist_path}" 'RunAtLoad' -bool true
		/usr/bin/defaults write "${plist_path}" 'Debug' -bool true

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
	if [[ $? -eq 0 ]]; then
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

# Validate executable file at /usr/local/bin/SwitchAudioSource

if command -v "$Switch_Audio_Source" &>/dev/null; then
    echo "$Switch_Audio_Source is installed and can be run."
else
    echo "Error: $Switch_Audio_Source is not installed." >&2
    exit 1
fi


# Validate device_type using a case statement
# Temporarily set the style for case-insensitivity for 'case' comparisons
zstyle ':case' GLOB_CASE_SENSITIVE false

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
        echo "Allowed values are: input, output, system." >&2
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
fi

# Restore default case-sensitivity behavior (optional, good practice)
zstyle ':case' GLOB_CASE_SENSITIVE true

# MARK: MAIN
echo "Script parameters are valid. Proceeding..."

echo 'https://github.com/deweller/switchaudio-osx'
echo "Show  current ${device_type} device, json format with labels..."
${Switch_Audio_Source} -c -f json -t ${device_type}
echo "List  all ${device_type} devices, cli format..."
# /usr/local/bin/SwitchAudioSource -a -f cli -t output


allAudioSources=$(${Switch_Audio_Source} -a -f cli -t ${device_type})
allAudioSourcesStatus=$?

if [[ ${allAudioSourcesStatus} -ne 0 || -z "${allAudioSources}" ]]; then
    echo "Error: Unable to enumerate ${device_type} audio devices with ${Switch_Audio_Source}." >&2
    exit 1
fi

echo "${allAudioSources}"

echo "Find requested device..."
echo "${allAudioSources}" | grep --ignore-case -e "${device_name_uid}"

# grep for the first source that is like the input $device_name_uid, then use awk to get the device_UID as the last item.
selectAudioSourceUID=$(echo "${allAudioSources}" | grep --ignore-case --max-count=1 -e "${device_name_uid}" | /usr/bin/awk -F',' '{print $NF}')

# grep for the first source that is like the input $device_name_uid, then use awk to get the device_name as the first item.
selectAudioSourceName=$(echo "${allAudioSources}" | grep --ignore-case --max-count=1 -e "${device_name_uid}" | /usr/bin/awk -F',' '{print $1}')

/bin/launchctl bootout loginwindow "${PathToLaunchAgent}" 2>/dev/null
/bin/launchctl bootout system "${PathToLaunchDaemon}" 2>/dev/null

# MARK: write_launchd_script
write_launchd_script "${LaunchScript}"

# MARK: Create LaunchAgent
echo "Creating LaunchAgent plist file ${PathToLaunchAgent}..."
write_launchd_program_arguments "${PathToLaunchAgent}"

# MARK: test no root flag
# Does this need to run as root? Removing this to test.
# /usr/bin/defaults write "${PathToLaunchAgent}" 'UserName' -string "root"
/usr/bin/defaults write "${PathToLaunchAgent}" 'LimitLoadToSessionType' -array "Aqua" "LoginWindow"

# MARK: Create LaunchDaemon
echo "Creating LaunchDaemon plist file ${PathToLaunchDaemon}..."
write_launchd_program_arguments "${PathToLaunchDaemon}"

# Enable tracing without trace output
# { set -x; } 2>/dev/null

# MARK: Set file ownership, privileges, remove quarantine
set_launchd_plist_privs_quarantine "${PathToLaunchAgent}"
set_launchd_plist_privs_quarantine "${PathToLaunchDaemon}"

# MARK: Check launchd plist syntax
check_plist "${PathToLaunchAgent}"
check_plist "${PathToLaunchDaemon}"

# MARK: BOOSTRAPS
/bin/launchctl enable loginwindow/${LaunchAgentLabel} 2>&1
/bin/launchctl bootstrap loginwindow "${PathToLaunchAgent}" 2>&1
/bin/launchctl enable system/${LaunchDaemonLabel} 2>&1
/bin/launchctl bootstrap system "${PathToLaunchDaemon}" 2>&1
/bin/launchctl kickstart system/${LaunchDaemonLabel} 2>&1

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

