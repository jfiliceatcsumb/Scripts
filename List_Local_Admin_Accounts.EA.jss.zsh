#!/bin/zsh --no-rcs


# CREDIT: https://community.jamf.com/t5/jamf-pro/how-to-find-all-the-local-users-with-admin-right-or-not/m-p/130519/highlight/true#M119629

## A list of the known local admins to be excluded, delimited with pipe |
known_admins="admin|jamf0001"

## Initialize array
admin_list=()

for username in $(/usr/bin/dscl . list /Users UniqueID | awk '$2 > 500 {print $1}' | egrep --invert-match -e "^_" | egrep --invert-match -e "${known_admins}" ); do
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

# /usr/bin/dscl . list /Users UniqueID | awk '$2 > 500 {print $1}' | egrep --invert-match -e "${known_admins}" -e "^_"
# ## List all users UID
# /usr/bin/dscl . list /Users UniqueID
# ## User account IDs are greater than 500. Filter by accounts ID greater than 500
# awk '$2 > 500 {print $1}'
# ## Filter out service accounts, which begin with _underscore_
# egrep --invert-match -e "^_"
# ## Filter out known admins list
# egrep --invert-match -e "${known_admins}" 
# 
# dscl . list /Users UniqueID |     awk '$2 > 1000 {print $1}'
# # To list all Active Directory mobile accounts on a Mac, you can use the dscl command in the Terminal. Specifically, you can use the command 
# dscl . list /Users UniqueID | awk '$2 > 1000 {print $1}'
# # to get a list of user accounts, and then filter for those that have Active Directory as their authentication authority. You can then use another command like 
# dscl . -read /Users/<username> AuthenticationAuthority
# # to verify if an account is associated with Active Directory. Alternatively, you can use System Settings -> Users & Groups to view all user accounts, including those that are mobile. 
