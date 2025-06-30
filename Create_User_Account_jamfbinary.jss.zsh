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
username="${4:-lapsadmin}"
displayName="${5:-LAPS Admin}"
password="${6:-P@55w0rd}"
admin="${7:-no}"
hidden="${8:-yes}"
SecureToken="${9:-yes}"

credentials_decoded=$(base64 -d <<< "$password")
if [[ $(awk -F: '{print NF-1}' <<< "$credentials_decoded") -eq 1 ]]; then
	account_shortname=$(awk -F: '{print $1}' <<< "$credentials_decoded")
	account_password=$(awk -F: '{print $NF}' <<< "$credentials_decoded")
else
	writelog "[get_user_details] ERROR: Supplied credentials are in the incorrect form, so exiting..."
	exit 1
fi
# determine next available UID
highestUID=$( dscl . -list /Users UniqueID | /usr/bin/awk '$2>m {m=$2} END { print m }' )
nextUID=$(( highestUID+1 ))

# create the account
/usr/bin/dscl . create "/Users/$username"
/usr/bin/dscl . create "/Users/$username" UserShell /bin/zsh
/usr/bin/dscl . create "/Users/$username" RealName "$displayName" 
/usr/bin/dscl . create "/Users/$username" UniqueID "$nextUID"
/usr/bin/dscl . create "/Users/$username" PrimaryGroupID 20

if [[ "$SecureToken" = "yes" ]]; then
	/usr/bin/dscl . create "/Users/$username" AuthenticationAuthority ';SecureToken;'
fi

/usr/bin/dscl . passwd "/Users/$username" "$password"


# make the account admin, if specified
if [[ "$admin" = "yes" ]]; then
    /usr/bin/dscl . append /Groups/admin GroupMembership "$username"
fi

# hide the account, if specified
if [[ "$hidden" = "yes" ]]; then
    /usr/bin/dscl . create "/Users/$username" IsHidden 1
    /usr/bin/dscl . create "/Users/$username" NFSHomeDirectory "/private/var/$username"
else
    /usr/bin/dscl . create "/Users/$username" NFSHomeDirectory "/Users/$username"
fi

echo "Secure Token Status for $username:"
/usr/sbin/sysadminctl -secureTokenStatus "$username"

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
