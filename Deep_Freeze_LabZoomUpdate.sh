#!/bin/bash

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script requires .
# Run it with no arguments. 
# 
# Use as script in Jamf JSS.
# This script should only be targeted to Macs with Deep Freeze 7.2x or later



# Change History:
# 2021/06/09:	Creation.
#

SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

# Jamf JSS Parameters 1 through 3 are predefined as mount point, computer name, and username

pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3

shift 3
# Shift off the $1 $2 $3 parameters passed by the JSS so that parameter 4 is now $1

echo pathToScript=$pathToScript
echo mountPoint=$mountPoint
echo computerName=$computerName
echo userName=$userName

# set alias for PlistBuddy and several others so I don't have to specify full path.
# Prefix sudo path because I'm using it here for all commands.
# If I want to run a command without the alias, then specify the full path.
alias PlistBuddy="/usr/libexec/PlistBuddy"
alias chown="/usr/sbin/chown"
alias chmod="/bin/chmod"
alias ditto="/usr/bin/ditto"
alias defaults="/usr/bin/defaults"
alias rm="/bin/rm"
alias cp="/bin/cp"
alias mkdir="/bin/mkdir"
alias sudo=/usr/bin/sudo


# Example:
# /bin/ls -FlOah "${SCRIPTPATH}"

write_script() {
	cat > "$1" <<-EOF
	#!/bin/sh

	/usr/local/bin/jamf policy -event LabZoomUpdate -randomDelaySeconds 15

	exit 0
	EOF

}


write_script "/usr/local/bin/Jamf_LabZoomUpdate.sh"

# Delete existing Deep Freeze schedule with same name
/usr/local/bin/deepfreeze schedule delete --name "Jamf_LabZoomUpdate"

# Add script to Deep Freeze scripts, then list all.
/usr/local/bin/deepfreeze schedule scripts --add "/usr/local/bin/Jamf_LabZoomUpdate.sh"
/usr/local/bin/deepfreeze schedule scripts --list

# Add Deep Freeze maintenance schedule
/usr/local/bin/deepfreeze schedule add --name "Jamf_LabZoomUpdate" --enable on --day sunday --begin "2:00" --end "2:15" --lockuser on --warnuser "15" --runscript "Jamf_LabZoomUpdate.sh"


exit
