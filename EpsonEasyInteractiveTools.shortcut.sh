#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# http://it.csumb.edu



# Description.
# 
# Postponed script execution in DeployStudio. Commands must run as root.

# Change History:
# 2015/11/06:	Creation.
#


SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

echo "***Begin $SCRIPTNAME script***"
/bin/date


# set -x # For debugging, show commands.

# Start here
echo 'Only If Epson Easy Interactive Tools app exists, then'
if [ -e "/Applications/Easy Interactive Tools Ver.3/Easy Interactive Tools.app" ] 
then
	echo 'Delete existing symbolic link or alias at target location; error if not exist.'
	/bin/rm -fv "${HOME}/Desktop/Easy Interactive Tools.app"

	echo 'Create symbolic link at target location.'
	/bin/ln -shfFv "/Applications/Easy Interactive Tools Ver.3/Easy Interactive Tools.app" "${HOME}/Desktop/Easy Interactive Tools.app"

	# Else, echo not found.
else
	echo 'Epson Easy Interactive Tools app not found'
fi

echo "***End $SCRIPTNAME script***"
/bin/date

exit 0
