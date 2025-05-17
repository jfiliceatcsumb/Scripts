#!/bin/zsh --no-rcs


# CREDIT: https://community.jamf.com/t5/jamf-pro/how-to-find-all-the-local-users-with-admin-right-or-not/m-p/130519/highlight/true#M119629

## A list of the known local admins to be excluded
known_admins="admin|jamf0001"

## Initialize array
admin_list=()

for username in $(/usr/bin/dscl . list /Users UniqueID | awk '$2 > 500 && $2 < 1000 {print $1}' | egrep -v "${known_admins}"); do
    if [[ $(/usr/sbin/dseditgroup -o checkmember -m "$username" admin | grep "^yes") ]]; then
    ## Any reported accounts are added to the array list
        admin_list+=("${username}")
    fi
done

## Prints the array's list contents
if [[ "${admin_list[@]}" != "" ]]; then
    echo "<result>${admin_list[@]}</result>"
else
    echo "<result>[ None ]</result>"
fi

exit 0