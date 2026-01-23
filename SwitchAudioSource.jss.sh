#!/bin/zsh --no-rcs

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script requires /usr/local/bin/SwitchAudioSource version 1.1.0 or newer.
# Sets  audio output to script input parameter. 
# If multiple values are provided, the script will stop after setting it to the first match. 
# Run by Jamf Pro.
# 
# PARAMETERS:
# 4: device type (input/output/system/all).  Defaults to output
# 5: Audio device name or UID (case insensitive grep matching)

# 
# Change History:
# 2025/12/10:	Creation.
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

device_type="${1:-output}"
device_name_uid="${2:-builtin}"
mute_mode="${3:-unmute}"

# --- Validation Logic ---

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


# Restore default case-sensitivity behavior (optional, good practice)
zstyle ':case' GLOB_CASE_SENSITIVE true

echo "Script parameters are valid. Proceeding..."

### Production path:
PathToLaunchAgent="/Library/LaunchAgents/edu.csumb.it.SwitchAudioSource.${device_type}.plist"
### TESTING locally path:
# PathToLaunchAgent="$HOME/edu.csumb.it.SwitchAudioSource.${device_type}.plist"

Label=$(/usr/bin/basename ${PathToLaunchAgent} .plist)

# Usage: 
# SwitchAudioSource [-a] [-c] [-t type] [-n] -s device_name | -i device_id | -u device_uid
# 	-a             : shows all devices
# 	-c             : shows current device
# 	-f format      : output format (cli/human/json). Defaults to human.
# 	-t type        : device type (input/output/system).  Defaults to output.
# 	-m mute_mode : sets the mute status (mute/unmute/toggle). (version 1.2.0+)
# 	-n             : cycles the audio device to the next one
# 	-i device_id   : sets the audio device to the given device by id
# 	-u device_uid  : sets the audio device to the given device by uid or a substring of the uid
# 	-s device_name : sets the audio device to the given device by name
# 

echo 'https://github.com/deweller/switchaudio-osx'
echo "Show  current ${device_type} device, cli format..."
/usr/local/bin/SwitchAudioSource -c -f cli -t ${device_type}
echo "List  all ${device_type} devices, cli format..."
# /usr/local/bin/SwitchAudioSource -a -f cli -t output


# allAudioSources=$(/usr/local/bin/SwitchAudioSource -a -f cli -t output | grep --ignore-case -e "builtin")
allAudioSources=$(/usr/local/bin/SwitchAudioSource -a -f cli -t ${device_type})

echo "${allAudioSources}"

echo "Find requested device..."
echo "${allAudioSources}" | grep --ignore-case -e "${device_name_uid}"

# grep for the first source that is like the input $device_name_uid, then use awk to get the device_UID as the last item.
selectAudioSourceUID=$(echo "${allAudioSources}" | grep --ignore-case --max-count=1 -e "${device_name_uid}" | /usr/bin/awk -F',' '{print $NF}')

# grep for the first source that is like the input $device_name_uid, then use awk to get the device_name as the first item.
selectAudioSourceName=$(echo "${allAudioSources}" | grep --ignore-case --max-count=1 -e "${device_name_uid}" | /usr/bin/awk -F',' '{print $1}')


# echo	'/usr/local/bin/SwitchAudioSource -t ${device_type} -u "${selectAudioSourceUID}" -m "${mute_mode}"'
# echo	"/usr/local/bin/SwitchAudioSource -t ${device_type} -u ${selectAudioSourceUID} -m ${mute_mode}"
# /usr/local/bin/SwitchAudioSource -t "${device_type}" -u "${selectAudioSourceUID}" -m "${mute_mode}"

LABEL=$(/usr/bin/basename ${PathToLaunchAgent} .plist)

#### TESTING--comment out bootout command 
/bin/launchctl bootout system "${PathToLaunchAgent}" 2>/dev/null

echo "Creating LaunchAgent plist file ${PathToLaunchAgent}..."
if [[ -n $selectAudioSourceName ]]; then
then
    /usr/bin/defaults delete "${PathToLaunchAgent}"
    /usr/bin/defaults write "${PathToLaunchAgent}" 'ProgramArguments' -array \
    "/usr/local/bin/SwitchAudioSource" \
    "-t" "${device_type}" \
    "-s" "${selectAudioSourceName}"
elif [[ -n $selectAudioSourceUID ]]; then
    /usr/bin/defaults delete "${PathToLaunchAgent}"
    /usr/bin/defaults write "${PathToLaunchAgent}" 'ProgramArguments' -array \
    "/usr/local/bin/SwitchAudioSource" \
    "-t" "${device_type}" \
    "-u" "${selectAudioSourceUID}"
else
	echo "Error: No device found for ${device_name_uid}" >&2
	exit 1
fi

/usr/bin/defaults write "${PathToLaunchAgent}" 'Label' -string "${LABEL}"
/usr/bin/defaults write "${PathToLaunchAgent}" 'StandardOutPath' -string "/private/var/log/${LABEL}_stdout.log"
/usr/bin/defaults write "${PathToLaunchAgent}" 'StandardErrorPath' -string "/private/var/log/${LABEL}_stderr.log"
/usr/bin/defaults write "${PathToLaunchAgent}" 'UserName' -string "root"
/usr/bin/defaults write "${PathToLaunchAgent}" 'LimitLoadToSessionType' -array "LoginWindow"
/usr/bin/defaults write "${PathToLaunchAgent}" 'KeepAlive' -bool false
/usr/bin/defaults write "${PathToLaunchAgent}" 'RunAtLoad' -bool true
/usr/bin/defaults write "${PathToLaunchAgent}" 'Debug' -bool true

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

# Enable tracing without trace output
# { set -x; } 2>/dev/null

# chmod flags:
# -f	Do not display a diagnostic message if chmod could not modify the mode for file.
# -h	If the file is a symbolic link, change the mode of the link itself rather than the file that the link points to.
# -v	Cause chmod to be verbose, showing filenames as the mode is modified.  
/usr/sbin/chown -fv 0:0 "${PathToLaunchAgent}"
/bin/chmod -fv 644 "${PathToLaunchAgent}"
# Remove quarantine extended attributes
/usr/bin/xattr -d com.apple.quarantine "${PathToLaunchAgent}"
/usr/bin/plutil -lint "${PathToLaunchAgent}"
/usr/bin/plutil -p "${PathToLaunchAgent}"

#### TESTING--comment out bootstrap command
/bin/launchctl enable system/${LABEL}
/bin/launchctl bootstrap system "${PathToLaunchAgent}" 2>/dev/null

# Disable tracing without trace output
# { set +x; } 2>/dev/null

echo "***End $SCRIPTNAME script***"

exit 0
