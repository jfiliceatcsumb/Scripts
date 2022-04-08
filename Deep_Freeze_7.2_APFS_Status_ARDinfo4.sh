#!/bin/sh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# http://csumb.edu/it




# This script should only be targeted to Macs with Deep Freeze 7.2x or later

# Change History:
# 2019/10/16:	Creation.
#

SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

echo "***Begin $SCRIPTNAME script***"
/bin/date

# check whether deep Freeze 7 or older is installed. 
# If Deep Freeze 7, then get status and set $deepfreezeStatus
# If Deep Freeze classic, do nothing. 
# If neither, then set status to blank/default value.

if [ -e /usr/local/bin/deepfreeze ]
then
	set -x

	/usr/local/bin/deepfreeze ardinfo --set 4 

	set +x
    
fi


echo "***End $SCRIPTNAME script***"
/bin/date

exit 0
