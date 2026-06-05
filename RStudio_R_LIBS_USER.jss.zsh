#!/bin/zsh --no-rcs
# 
## #!/bin/bash --noprofile --norc


# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# This script requires .
# Run it with no arguments. 
# 
# Use as script in Jamf JSS.

# Set the R_LIBS_USER Environment Variable
# Instead of a script, you can declare a persistent system-level environment variable for that user. This ensures that any R interface—not just RStudio—uses the correct local folder.
# 
# On Linux / macOS:
# 
# ~/.Rprofile
# .libPaths(c("~/R/x86_64-pc-linux-gnu-library/${RShortVersion}", .libPaths()))
# 
# 
# Open the user's local profile file (~/.bashrc or ~/.zshrc).
# Add the following line at the end of the file:
# 
# export R_LIBS_USER="~/R/x86_64-pc-linux-gnu-library/${RShortVersion}"
#
# On Windows:
# Open the Start Menu, search for "Environment Variables," and select Edit environment variables for your account.
# Under the user variables section, click New....Set the Variable name to R_LIBS_USER.Set the Variable value to a local directory (e.g., C:\Users\YOUR_USERNAME\R\win-library).Click OK and restart RStudio.

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
# Enable tracing without trace output
# { set -x; } 2>/dev/null
# Disable tracing without trace output
# { set +x; } 2>/dev/null

# Example:
# /bin/ls -FlOah "${SCRIPTDIR}"

exit 0

