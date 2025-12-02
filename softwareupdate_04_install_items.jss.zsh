#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Run it with software update identifiers arguments. 
# 4:	RESTART = TRUE | FALSE
# 5:	ASU update label
# 6:	[ASU update label]
# 7:	[ASU update label]
# 8:	[ASU update label]
# 9:	[ASU update label]
# 10:	[ASU update label]
# 11:	[ASU update label]
# The script uses quoting to keep spaces in the identifier names.
# 
# Use as script in Jamf JSS.



SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

# Jamf JSS Parameters 1 through 3 are predefined as mount point, computer name, and username

pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3


shift 3
# Shift off the $1 $2 $3 parameters passed by the JSS so that parameter 4 is now $1

RESTART=""
if [[ "${1}" == "FALSE" ]]; then
	RESTART="FALSE"
else
	RESTART="TRUE"
fi
# Shift off parameter #4 so that we are only left with parameters for update labels
shift

echo "List all available updates..."
/usr/sbin/softwareupdate --list

# loop over parameters passed
while [ $# != 0 ]
do
	# Use if,then to check for any value in the variable.
	if [ "$1" != "" ]
	then
		echo "Downloading update for ${1}..."
		/usr/sbin/softwareupdate --download "$1"
		sleep 1
		if [[ "${RESTART}" == "TRUE" ]]; then
			echo "Installing update for ${1} (restart if required)..."
			/usr/sbin/softwareupdate --install "$1" --no-scan --agree-to-license --restart
		else
			echo "Installing update for ${1}..."
			/usr/sbin/softwareupdate --install "$1" --no-scan --agree-to-license
		fi
	fi
	shift
done

exit 0

