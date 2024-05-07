#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it


# This script is for Jamf Pro Extension Attribute to collect logs for Jamf Connect Privilege Elevation for Local Accounts
# https://learn.jamf.com/en-US/bundle/jamf-connect-documentation-current/page/Managing_Privilege_Elevation_with_Logs.html

# Credit: https://community.jamf.com/t5/jamf-connect/jamf-connect-2-33-0-admin-elevation-extension-attribute/m-p/313314/highlight/true#M3657

# This script expects Jamf Connect to be installed, but will exit gracefully if not.
# Run it with no arguments. 
# 
# Use as script in Jamf Pro Extension Attribute.


# Change History:
# 2024/05/06:	Creation.
#

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


# ##### Debugging flags #####
# debug bash script by enabling verbose “-v” option
# set -v
# debug bash script using noexec (Test for syntaxt errors)
# set -n
# identify the unset variables while debugging bash script
# set -u
# debug bash script using xtrace
# set -x

# Example:
# /bin/ls -FlOah "${SCRIPTDIR}"

#!/bin/zsh
  
# Path to the log file
log_file="/Library/Logs/JamfConnect/UserElevationReasons.log"
  
# Check if the log file exists
if [ ! -f "$log_file" ]; then
    # If the log file doesn't exist, output a specific message for the extension attribute
    echo "<result>No Jamf Connect privilege elevations</result>"
    exit 0
fi
  
# Get the most recent 3 entries from the log file
latest_log_entries=$(tail -n 3 "$log_file")
  
# # Begin the result string
# recent_times="<result>\n"
#   
# # Process each log entry
# echo "$latest_log_entries" | while read log_entry; do
#     # Extract the date/time from the log entry
#     gmt_date=$(echo $log_entry | awk '{print $1, $2}')
#   
#     # Convert GMT to Eastern Time
#     eastern_date=$(date -jf "%Y-%m-%d %H:%M:%S" -v"-5H" "$gmt_date" "+%Y-%m-%d %H:%M:%S")
#   
#     # Check if Daylight Saving Time is in effect
#     daylight_saving=$(date -v"-5H" -jf "%Y-%m-%d %H:%M:%S" "$gmt_date" "+%Z")
#   
#     if [ "$daylight_saving" = "EDT" ]; then
#         eastern_date=$(date -jf "%Y-%m-%d %H:%M:%S" -v"-4H" "$gmt_date" "+%Y-%m-%d %H:%M:%S")
#     fi
#   
#     # Extract the user information from the log entry
#     user_info=$(echo $log_entry | cut -d ' ' -f4-)
#   
#     # Append the date/time and user information to the result string
#     recent_times+="$eastern_date $user_info\n"
# done
#   
# # End the result string
# recent_times+="</result>"
#   
# # Output for Jamf Pro extension attribute
# echo -e "$recent_times"

echo "<result>$latest_log_entries</result>"

exit 0

