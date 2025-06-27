#!/bin/bash

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# http://csumb.edu/it



# This script requires superuser privileges.
# Run it with no arguments. 
# 



SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

/bin/echo "***Begin $SCRIPTNAME script***"
/bin/date


# Jamf script to disable Adobe Creative Cloud BrowserBasedAuthentication
# Tested on macOS 15 (Sequoia) and earlier

ServiceConfig="/Library/Application Support/Adobe/OOBE/Configs/ServiceConfig.xml"


# Edit file to set BrowserBasedAuthentication to false
  if [ -f "$ServiceConfig" ]; then
#   	sed using pipe | as its delimiter.
	sed -i 's|<feature><name>BrowserBasedAuthentication</name><enabled>true</enabled></feature>|<feature><name>BrowserBasedAuthentication</name><enabled>false</enabled></feature>|g'  "$ServiceConfig"
else
# 	If file does not exist, then simply create it.
	cat << EOF > "$ServiceConfig" 
<config><feature><name>BrowserBasedAuthentication</name><enabled>false</enabled></feature></config>
EOF
fi

# Be sure to set ownership and permissions on the plist just in case.
/usr/sbin/chown -f 0:0 "$ServiceConfig"
/bin/chmod -f 644 "$ServiceConfig"
# Adobe CC updates will often reinstall these launch agents. 
# To prevent this Set file immutability
/usr/bin/chflags schg "$ServiceConfig"



/bin/echo "***End $SCRIPTNAME script***"
/bin/date
exit 0

# 