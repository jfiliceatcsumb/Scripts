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
# 5: Audio device name or UID (grep matching)
# 6: sets the mute status (mute/unmute/toggle).  For input/output only.

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

device_type=${1:="output"}
device_name_uid=${2:="builtin"}
mute_mode=${3:="unmute"}

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
        echo "Error: Invalid device_type value: '$device_type'" >&2
        echo "Allowed values are: input, output, system." >&2
        exit 1
        ;;
esac

case "${mute_mode}" in
    mute)
        # Valid value, assign the value as lower-case. 
				# SwitchAudioSource is case-senstive
        mute_mode="mute"
        echo "Valid device_type: $device_type"
        ;;
    unmute)
        # Valid value, assign the value as lower-case. 
				# SwitchAudioSource is case-senstive
        mute_mode="unmute"
        echo "Valid device_type: $device_type"
        ;;
    toggle)
        # Valid value, assign the value as lower-case. 
				# SwitchAudioSource is case-senstive
        mute_mode="toggle"
        echo "Valid device_type: $device_type"
        ;;
    *)
        # Valid value, assign the value as lower-case. 
				# SwitchAudioSource is case-senstive
        mute_mode=""
        echo "No mute_mode set"
        ;;
esac

# Restore default case-sensitivity behavior (optional, good practice)
zstyle ':case' GLOB_CASE_SENSITIVE true

echo "Script parameters are valid. Proceeding..."

### Production path:
PathToLaunchDaemon="/Library/LaunchDaemons/edu.csumb.it.SwitchAudioSource.output.plist"
### TESTING locally path:
# PathToLaunchDaemon="$HOME/edu.csumb.it.SwitchAudioSource.${device_type}.plist"

Label=$(/usr/bin/basename ${PathToLaunchDaemon} .plist)

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

selectAudioSource=$(echo "${allAudioSources}" | grep --ignore-case -e "${device_name_uid}" | awk -F',' '{print $1}')
# /usr/local/bin/SwitchAudioSource -t output -s 'HDMI' | logger
if [[ -n $selectAudioSource ]]
then
	echo	'/usr/local/bin/SwitchAudioSource -t ${device_type} -s "${selectAudioSource}"'
	echo	"/usr/local/bin/SwitchAudioSource -t ${device_type} -s ${selectAudioSource}"
	/usr/local/bin/SwitchAudioSource -t "${device_type}" -s "${selectAudioSource}"
fi

LABEL=$(/usr/bin/basename ${PathToLaunchDaemon} .plist)

#### TESTING--comment out bootout command 
/bin/launchctl bootout system "${PathToLaunchDaemon}" 2>/dev/null

echo "Creating LaunchDaemon plist file ${PathToLaunchDaemon}"
/usr/bin/defaults write "${PathToLaunchDaemon}" 'Label' -string "${LABEL}"
/usr/bin/defaults write "${PathToLaunchDaemon}" 'ProgramArguments' -array "/usr/local/bin/SwitchAudioSource" \
"-t" "${device_type}" \
"-s" "\"${selectAudioSource}\"" \
"-m" "${mute_mode}"
# /usr/bin/defaults write "${PathToLaunchDaemon}" 'LimitLoadToSessionType' -array "LoginWindow" "Aqua"
/usr/bin/defaults write "${PathToLaunchDaemon}" 'LimitLoadToSessionType' "LoginWindow"
/usr/bin/defaults write "${PathToLaunchDaemon}" 'KeepAlive' -bool false
/usr/bin/defaults write "${PathToLaunchDaemon}" 'RunAtLoad' -bool true

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
{ set -x; } 2>/dev/null

# chmod flags:
# -f	Do not display a diagnostic message if chmod could not modify the mode for file.
# -h	If the file is a symbolic link, change the mode of the link itself rather than the file that the link points to.
# -v	Cause chmod to be verbose, showing filenames as the mode is modified.  
chown -fv 0:0 "${PathToLaunchDaemon}"
chmod -fv 644 "${PathToLaunchDaemon}"

/usr/bin/plutil -lint "${PathToLaunchDaemon}"
/usr/bin/plutil -p "${PathToLaunchDaemon}"

#### TESTING--comment out bootstrap command
/bin/launchctl enable system/${LABEL}
/bin/launchctl bootstrap system "${PathToLaunchDaemon}"

# Disable tracing without trace output
{ set +x; } 2>/dev/null

echo "***End $SCRIPTNAME script***"

exit 0
