#!/bin/zsh

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
# 4: device type (input/output/system).  Defaults to output
# 5-11: Audio device names
# 
# Change History:
# 2022/MM/DD:	Creation.
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

device_type=${1:="output"}

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

echo "https://github.com/deweller/switchaudio-osx"
echo "List  all output devices, cli format..."
/usr/local/bin/SwitchAudioSource -a -f cli -t output
echo "Show  current output device, cli format..."
/usr/local/bin/SwitchAudioSource -c -f cli -t output


allAudioSources=$(/usr/local/bin/SwitchAudioSource -a -f human -t output)
| grep --ignore-case -e "Built-in")
echo "${allAudioSources}"


selectAudioSource=$(echo "${allAudioSources}" | grep "{$1}")
# /usr/local/bin/SwitchAudioSource -t output -s 'HDMI' | logger
if [[ -n $selectAudioSource ]]
then
	/usr/local/bin/SwitchAudioSource -t output -s "${selectAudioSource}"
fi

echo "***End $SCRIPTNAME script***"

exit 0
