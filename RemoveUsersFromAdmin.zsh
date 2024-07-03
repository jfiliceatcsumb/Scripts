#!/bin/zsh

# these local accounts will not be removed from admins
# one account name per line; keep the beginning and closing quotes

# exceptionsList="jamf0001
# admin
# _sophos
# _sophosencryption"

set -x 

exceptionsList=(jamf0001 admin _sophos _sophosencryption)
echo $exceptionsList
# list all users with UIDs greater than or equal to 500

localUsers=$( /usr/bin/dscl /Local/Default -list /Users uid | /usr/bin/awk '$2 >= 500 { print $1 }' )
echo "List of local accounts:
$localUsers\n"

localAdmins=()
localAdmins=($(/usr/bin/dscl /Local/Default -read /Groups/admin GroupMembership | /usr/bin/sed 's/GroupMembership: //1'))
echo "list of local admin accounts:"
echo "$localAdmins\n"

# remove all but those in exceptions list from local admins group

for aUser in ${localAdmins}
do
	echo "$aUser"
	echo "${exceptionsList[@]}" | /usr/bin/grep -w "$aUser"
	if [ ! $( echo "${exceptionsList[@]}" | /usr/bin/grep -w "$aUser" ) ] ; then
# 		/usr/sbin/dseditgroup -o edit -d "$aUser" -t user admin
	echo "Removed user: $aUser from admins group"

done

# while IFS= read aUser
# do
# 	if [ ! $( /usr/bin/grep -w "$aUser" <<< "$exceptionsList" ) ] ; then
# # 		/usr/sbin/dseditgroup -o edit -d "$aUser" -t user admin
# 		echo "Removed user: $aUser from admins group"
# 	fi
# 
# done <<< "$localUsers"

exit 0
