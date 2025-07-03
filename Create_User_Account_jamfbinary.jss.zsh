#!/bin/zsh

SCRIPTNAME=$(/usr/bin/basename "$0")
SCRIPTDIR=$(/usr/bin/dirname "$0")

# Jamf JSS Parameters 1 through 3 are predefined as mount point, computer name, and username

pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3


echo "pathToScript=$pathToScript"
echo "mountPoint=$mountPoint"
echo "computerName=$computerName"
echo "userName=$userName"

# set -x

# new user account details
# passhash is base64 encoded password
# base64  <<< "password"
NewAccount="${4:-lapsadmin}"
RealName="${5:-LAPS Admin}"
passhash="${6}"
admin="${7:-no}"
hidden="${8:-yes}"
secureTokenAllowed="${9:-yes}"
Picture="${10:-/Library/User Pictures/Nature/Zen.heic}"

# append flags to command, based upon script parameters
createAccountFlags=""

# Important Note: Zsh, by default, treats the expanded variable as a single word, even if it contains spaces, which is different from Bash's word-splitting behavior. 
# This means sam deploy -g --guided $aws_options would likely pass --profile test-name --region eu-west-2 as a single argument
# To handle multiple arguments correctly, especially those containing spaces, use arrays. 
# 	LS_OPTIONS=(--color=auto --group-directories-first)
# 	ls $LS_OPTIONS

if [[ "$secureTokenAllowed" =~ "[Yy][Ee][Ss]" ]]; then
	createAccountFlags+=( -secureTokenAllowed)
fi

# make the account admin, if specified
if [[ "$admin" =~ "[Yy][Ee][Ss]" ]]; then
	createAccountFlags+=( -admin)
fi

# hide the account, if specified
if [[ "$hidden" =~ "[Yy][Ee][Ss]" ]]; then
	createAccountFlags+=( -hiddenUser -home /private/var/$NewAccount)
fi

# Apple-installed user photos have .heic or .tif file extensions. 
# If "$Picture" does not exist, try alternate filename extension. 
if [[ ! -e "$Picture" ]]; then
# Determine whether provided filename suffix is ".heic" 
	FilenameSufix=$(echo "$Picture" | /usr/bin/grep --only-matching '\.heic$')
# ### HEIC  ###
	if [[ "$FilenameSufix" = ".heic" ]]; then
# change pathname to .tif
		PictureTif=$(echo "$Picture" | sed 's|.heic|.tif|' )
# If .tif pathname exists, then we use it instead.
		if [[ -e "$PictureTif" ]]; then
			Picture="$PictureTif"
		else
# Or we set Picture to empty string
			Picture=""
		fi
	else
#  ### TIF ###
		FilenameSufix=$(echo "$Picture" | /usr/bin/grep --only-matching '\.tif$')
		if [[ "$FilenameSufix" = ".tif" ]]; then
# change pathname to .heic
			PictureHEIC=$(echo "$Picture" | sed 's|.tif|.heic|' )
# If .heic pathname exists, then we use it instead.
			if [[ -e "$PictureHEIC" ]]; then
				Picture="$PictureHEIC"
			else
	# Or we set Picture to empty string
				Picture=""
			fi
		fi
	fi
fi


if [[ "$Picture" != "" ]]; then
	/usr/local/bin/jamf createAccount -stopConsoleLogs -verbose -username "$NewAccount" -realname "$RealName" -passhash "$passhash" -picture "$Picture" -suppressSetupAssistant $createAccountFlags
else
		/usr/local/bin/jamf createAccount -stopConsoleLogs -verbose -username "$NewAccount" -realname "$RealName" -passhash "$passhash" -suppressSetupAssistant $createAccountFlags
fi

# Tell system to create account user profile.
echo "Creating home directory for $NewAccount using /usr/sbin/createhomedir..."
/usr/sbin/createhomedir -c -l -u $NewAccount


echo "Secure Token Status for $NewAccount:"
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
