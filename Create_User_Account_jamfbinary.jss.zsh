#!/bin/zsh

SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTDIR=`/usr/bin/dirname "$0"`

# Jamf JSS Parameters 1 through 3 are predefined as mount point, computer name, and username

pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3


echo "pathToScript=$pathToScript"
echo "mountPoint=$mountPoint"
echo "computerName=$computerName"
echo "userName=$userName"


# new user account details
# passhash is base64 encoded password
# base64  <<< "password"
NewAccount="${4:-lapsadmin}"
RealName="${5:-LAPS Admin}"
passhash="${6}"
admin="${7:-no}"
hidden="${8:-yes}"
secureTokenAllowed="${9:-yes}"
Picture="${10:-}"

# append flags to command, based upon script parameters
createAccountFlags=""

if [[ "$secureTokenAllowed" = "yes" ]]; then
	createAccountFlags="$createAccountFlags -secureTokenAllowed"
fi

# make the account admin, if specified
if [[ "$admin" = "yes" ]]; then
	createAccountFlags="$createAccountFlags -admin"
fi

# hide the account, if specified
if [[ "$hidden" = "yes" ]]; then
	createAccountFlags="$createAccountFlags -hiddenUser -home /private/var/$NewAccount"
fi

/usr/local/bin/jamf createAccount -username "$NewAccount" -realname "$RealName" -passhash "$passhash" -picture "$Picture" -suppressSetupAssistant $createAccountFlags

# Tell system to create account user profile.


echo "Secure Token Status for $username:"
/usr/sbin/sysadminctl -secureTokenStatus "$NewAccount"


echo 
echo "Current list of volume owners:"
/usr/bin/fdesetup list -extended
/usr/sbin/diskutil apfs listUsers /


exit

: <<JAMFHELP
Usage:	 jamf createAccount -username <username> -realname <Real Name> 
		 [-password <password>] [-prompt] [-passhash <passhash>] [-home </path/to/home/directory>] 
		 [-hint <hint>] [-shell <shell>] [-picture <picture>]
		 [-admin] [-secureTokenAllowed] [-secureSSH] [-hiddenUser] [-networkUser] [-suppressSetupAssistant]

	 -username 			 The user's user name 

	 -realname 			 The user's real name

	 -password 			 The password of the user

	 -prompt 			 prompts user to enter a password for the user account

	 -passhash 			 The hashed password of the user

	 -home 				 The location of the user's home directory

	 -hint 				 The hint displayed to the user

	 -shell 			 The user's default shell

	 -picture 			 The user's picture for the Login window

	 -admin 			 This flag adds the user to the admin group.

	 -secureTokenAllowed 		 This flag allows the user account to be the first one on the computer that is granted a secure token.

	 -hiddenUser 			 Creates an account with a UID under 500 and hides it

	 -networkUser 			 Creates an account with a UID over 1025

	 -secureSSH 			 Modifies the group com.apple.ssh_access to restrict access to only this user

	 -suppressSetupAssistant 	 The Setup Assistant will not show on first login for this user
JAMFHELP
