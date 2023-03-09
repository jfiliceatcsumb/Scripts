#!/bin/sh
## postinstall

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it


# Sophos Central Endpoint: Installer command line options for Windows and Mac
# https://community.sophos.com/kb/en-us/127045#macArguments
# https://docs.sophos.com/central/Customer/help/en-us/PeopleAndDevices/ProtectDevices/EndpointProtection/CentralMacCommandLineOptions/index.html#mac-examples

# 
# For best results, use as postinstall script in a PKG installer.


# Change History:
# 2019/12/16:	Creation.
# 2021/02/17:	Added chmod commands per KB article
# 				https://support.sophos.com/support/s/article/KB-000035045
#				Removed --products all from command line. 
# 				We just want the products to be specified in SophosCloudConfig.plist
# 				

SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTPATH=`/usr/bin/dirname "$0"`

pathToScript=$0
pathToPackage=$1
targetLocation=$2
targetVolume=$3



# set alias for PlistBuddy and several others so I don't have to specify full path.
# Prefix sudo path because I'm using it here for all commands.
# If I want to run a command without the alias, then specify the full path.
alias PlistBuddy="/usr/libexec/PlistBuddy"
alias chown="/usr/sbin/chown"
alias chmod="/bin/chmod"
alias ditto="/usr/bin/ditto"
alias defaults="/usr/bin/defaults"
alias rm="/bin/rm"
alias cp="bin/cp"
alias mkdir="/bin/mkdir"
alias sudo=/usr/bin/sudo


# Example:
# /bin/ls -FlOah "${SCRIPTPATH}"

chmod a+x "${SCRIPTPATH}"/Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer
chmod a+x "${SCRIPTPATH}"/Sophos\ Installer.app/Contents/MacOS/tools/com.sophos.bootstrap.helper
"${SCRIPTPATH}"/Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer --quiet --install

exit 0

# Usage:
#     Sophos Installer [--install|--quiet] [--nofeedback] [--traillogging] [--mcsPreferredDomainName] [--tamper_password <tamper password>]
#                      [[--products <product> ...]  [--customertoken <customer token>] [--mgmtserver <MCS server>]]
#                      [--messagerelays <message relay> ...]
#                      [--proxyaddress <proxy address> --proxyport <proxy port> [--proxyusername <proxy username> --proxypassword <proxy password>]]
#                      [--devicegroup <device group>]
#                      [--domainnameoverride <domain name>] [--computernameoverride <computer name>] [--computerdescriptionoverride <computer description>]
#                      
# 
# options: 
#     --install                  => install product without a ui
#     --quiet                    => install product without a ui
#     --nofeedback                   => configure endpoint to not send installation telemetry
#     --traillogging                 => enable the logging of message content between the endpoint and Sophos Central during installation
#     --mcsPreferredDomainName       => override computername/username with domainname/username during registration
# 
# arguments: 
#     tamper password        => tamper protection password enables installation over a tamper protected on-premise managed endpoint
#     product                => space separated list of valid products:
#                                   intercept,mdr,antivirus,deviceEncryption,ztna,all,xdr
#     customer token         => token used to associate endpoint with customer account in Central
#     MCS server             => Sophos Central server name
#     message relay          => space separated list of message relay addresses including the port 8190
#                                   format: <server name or IP address>:8190
#     proxy address          => custom proxy to use; server name or IP address
#     proxy port             => the port for the proxy; a number between 1 and 65535
#     proxy username         => the username for the proxy
#     proxy password         => the password for the proxy
#     device group           => Central device group to join the endpoint to. If it doesn't exist, it will be created.
#     domain name            => overrides the domain name of the computer to be used in Central
#     computer name          => overrides the name of the computer to be used in Central
#     computer description   => overrides the description of the computer to be used in Central
# 
# return codes:
#        0 => The installation was successful.
#        1 => The installation failed.
#        2 => Feature not implemented.
#        3 => An incompatible product is installed.
#        21 => User cancellation.
#        26 => An external file is missing.
#        27 => An external component is damaged.
#        30 => Path failed security check.
#        34 => Failed authentication.
#        35 => Failed tamper protection authentication.
#        36 => Incompatible system configuration.
# 
# notes:
#     The Sophos Installer must be run as root when the '--install' or '--quiet' option is specified.
#     Passwords cannot contain whitespace characters.
#     Override arguments cannot contain whitespace except the space character or any of the following characters: <>&'";,/
#     Other arguments cannot contain whitespace or any of the following characters: <>&'";,/
