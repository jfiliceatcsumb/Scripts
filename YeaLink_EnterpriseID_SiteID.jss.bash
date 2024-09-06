#!/bin/bash

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script requires 2 arguments:
# EnterpriseId
# SiteId
# 
# Use as script in Jamf JSS.

# https://support.yealink.com/en/portal/knowledge/show?id=64fa80fe7128e45a498499b9

# Change History:
# 2022/MM/DD:	Creation.
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


# EnterpriseId
EnterpriseId='02481b9e'
# SitedId
SiteId='vjscjfyi'
# AutoRun
AutoRun=1
# SitedI'
RunApp=1  

# Check whether the path exists. If the path does not exist, create it
database_path="$HOME/Library/Application Support/Yealink USB Connect/Config"
if [ ! -d "$database_path" ]; then
    mkdir -p "$database_path"
fi  

# Generates the specified file
echo "{\"EnterpriseId\":\"$EnterpriseId\",\"SiteId\":\"$SiteId\",\"EnterpriseMode\":true}" > "$database_path/yucdeploy.json"
exit 0

