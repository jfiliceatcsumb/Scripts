#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Requires and tests for the existence of /Applications/Xcode.app and /Library/Developer/CommandLineTools
# Hard code cocoapods and activesupport version numbers, or pass as ordered input parameters

# Use as script in Jamf JSS.
# https://guides.cocoapods.org/using/getting-started.html#installation


# Change History:
# 2023/08/07:	Creation.
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

# Hard code version numbers here, or pass as ordered input parameters
# If input parameter is not defined, set to its value to hard coded version number.
cocoapodsVer=${1:-"1.12.1"}
activesupportVer=${2:-"6.1.7.4"}

# Requires Xcode to be installed first?

# Confirm Xcode and CommandLineTools are both installed.
# /Applications/Xcode.app
# /Library/Developer/CommandLineTools
# Test whether either are missing not installed; then exit.
if [[ ! -d "/Applications/Xcode.app" ]]; then
	echo "ERROR:Xcode.app is missing."
	echo "Exiting script."
	exit 1
fi

if [[ ! -d "/Library/Developer/CommandLineTools" ]]; then
	echo "ERROR:Command Line Tools are missing."
	echo "Exiting script."
	exit 1
fi

/usr/bin/xcode-select --switch /Library/Developer/CommandLineTools
/usr/bin/ruby -rrbconfig -e 'puts RbConfig::CONFIG["rubyhdrdir"]'


/usr/bin/gem uninstall cocoapods
/usr/bin/gem install activesupport -v ${activesupportVer}
/usr/bin/gem install cocoapods --version ${cocoapodsVer}

/usr/bin/xcode-select --switch /Applications/Xcode.app

exit 0

