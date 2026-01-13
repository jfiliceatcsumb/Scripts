#!/bin/zsh --no-rcs

# https://github.com/timsutton/osx-vm-templates/blob/master/scripts/xcode-cli-tools.sh

# set -x


# Get and install Xcode CLI tools

macOSversion=$(sw_vers -productVersion)
echo "macOSversion=$macOSversion"
# Just get the second version value after 10.
macOSversionMajor=$(echo $macOSversion | awk -F. '{print $1}')
macOSversionMinor=$(echo $macOSversion | awk -F. '{print $2}')
echo "macOSversionMajor=$macOSversionMajor"
echo "macOSversionMinor=$macOSversionMinor"

# if 
# macOS 11.x or newer
# or
# macOS 10.9.x or newer

# on 10.9+, we can leverage SUS to get the latest CLI tools
if [ $macOSversionMajor -gt 11 ] || [ $macOSversionMajor -eq 10 -a $macOSversionMinor -ge 9 ]; then
	# https://stackoverflow.com/questions/15371925/how-to-check-if-command-line-tools-is-installed
	echo "Check if command line tools are installed..."
	/usr/bin/xcode-select -p 2>&1
	/usr/bin/xcode-select -p 1>/dev/null
	CommandLineToolsCheck=${?}
	echo ${?}
	if [[ ${CommandLineToolsCheck} -ne 0 ]]
	then
		echo "Xcode Command Line Tools not found..."
		echo "Installing Xcode Command Line Tools..."
		
		# create the placeholder file that's checked by CLI updates' .dist code
		# in Apple's SUS catalog
		/usr/bin/touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
	else
		echo "Xcode Command Line Tools already installed..."
		echo "Checking for Xcode Command Line Tools updates..."
	fi
	PROD=$(/usr/sbin/softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')
# 	Strip "Label: "
	PROD=$(echo "$PROD" | sed -e 's/Label: //')

    # install it
	/usr/sbin/softwareupdate -i "$PROD" --verbose
	/bin/rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress 2>/dev/null

# on 10.7/10.8, we instead download from public download URLs, which can be found in
# the dvtdownloadableindex:
# https://devimages.apple.com.edgekey.net/downloads/xcode/simulators/index-3905972D-B609-49CE-8D06-51ADC78E07BC.dvtdownloadableindex
else
    [ "$macOSversionMinor" -eq 7 ] && DMGURL=http://devimages.apple.com.edgekey.net/downloads/xcode/command_line_tools_for_xcode_os_x_lion_april_2013.dmg
    [ "$macOSversionMinor" -eq 8 ] && DMGURL=http://devimages.apple.com.edgekey.net/downloads/xcode/command_line_tools_for_osx_mountain_lion_april_2014.dmg

    TOOLS=clitools.dmg
    curl "$DMGURL" -o "$TOOLS"
    TMPMOUNT=`/usr/bin/mktemp -d /tmp/clitools.XXXX`
    hdiutil attach "$TOOLS" -mountpoint "$TMPMOUNT"
    if [ "$macOSversionMinor" -eq 7 ]; then
        # using '-allowUntrusted' because Lion CLI tools are so old Apple never built another
        # package that doesn't have an expired CA cert. (Expired February 15, 2015)
        installer -pkg "$(find $TMPMOUNT -name '*.mpkg')" -allowUntrusted -target /
    else
        installer -pkg "$(find $TMPMOUNT -name '*.mpkg')" -target /
    fi
    hdiutil detach "$TMPMOUNT"
    rm -rf "$TMPMOUNT"
    rm "$TOOLS"
fi
exit
