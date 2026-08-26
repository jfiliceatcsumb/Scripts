#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it



# Client settings for \ CodeMeter to direct to license server.
# Modify variables Server1 and Server2.
# 
# Postponed script execution in DeployStudio. Commands must run as root.

# ### Set server address(es) here ###
Server1="${4:-127.0.0.1}"
Server2="${5:-255.255.255.255}"
# ###

SCRIPTNAME=$(/usr/bin/basename "$0")
SCRIPTDIR=$(/usr/bin/dirname "$0")

echo "***Begin $SCRIPTNAME script***"
/bin/date


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


# Stop Codemeter server.
# https://www.wibu.com/support/faq/faq/category/codemeter-general.html#faq-18
/bin/launchctl unload -F /Library/LaunchDaemons/com.wibu.CodeMeter.Server.plist
sleep 4

if [ -e /Library/Preferences/com.wibu.CodeMeter.Server.ini ]
then
# 	Delete lines starting with Server1= or Server2=
	/usr/bin/sed -e '/^Server1=/d' -e '/^Server2=/d'  -i "" /Library/Preferences/com.wibu.CodeMeter.Server.ini

# Delete lines with [ServerSearchList\Server1] and Address= together.
# 	/usr/bin/sed -e '/^[ServerSearchList\Server1]/d' 
# 	
# 	
# 	-e '/^Server2=/d' -e "/\[General\]/a\\
# 	Server2=$Server2" -i "" /Library/Preferences/com.wibu.CodeMeter.Server.ini
# 
# Delete lines with [ServerSearchList\Server2] and Address= together.
# 

# 	Delete lines with [ServerSearchList\Server1]
	/usr/bin/sed -e '/^\[ServerSearchList\\Server1\]/d' -i "" /Library/Preferences/com.wibu.CodeMeter.Server.ini

# 	Delete lines with [ServerSearchList\Server2]
	/usr/bin/sed -e '/^\[ServerSearchList\\Server2\]/d' -i "" /Library/Preferences/com.wibu.CodeMeter.Server.ini


# 	Append correct server lists.


fi

touch /Library/Preferences/com.wibu.CodeMeter.Server.ini

echo "[General]" >> /Library/Preferences/com.wibu.CodeMeter.Server.ini
echo "Server1=$Server1" >> /Library/Preferences/com.wibu.CodeMeter.Server.ini
echo "Server2=$Server2" >> /Library/Preferences/com.wibu.CodeMeter.Server.ini
echo "" >> /Library/Preferences/com.wibu.CodeMeter.Server.ini


echo "[ServerSearchList\Server1]" >> /Library/Preferences/com.wibu.CodeMeter.Server.ini
echo "Address=$Server1" >> /Library/Preferences/com.wibu.CodeMeter.Server.ini
echo "" >> /Library/Preferences/com.wibu.CodeMeter.Server.ini

echo "[ServerSearchList\Server2]" >> /Library/Preferences/com.wibu.CodeMeter.Server.ini
echo "Address=$Server2" >> /Library/Preferences/com.wibu.CodeMeter.Server.ini
echo "" >> /Library/Preferences/com.wibu.CodeMeter.Server.ini

chmod a+r /Library/Preferences/com.wibu.CodeMeter.Server.ini

/bin/launchctl load -wF /Library/LaunchDaemons/com.wibu.CodeMeter.Server.plist
sleep 4

echo "reading file /Library/Preferences/com.wibu.CodeMeter.Server.ini..."
cat /Library/Preferences/com.wibu.CodeMeter.Server.ini



echo "***End $SCRIPTNAME script***"
/bin/date

exit 0
