#!/bin/zsh

# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# http://csumb.edu/it



# Comments here
echo '*** Begin Set_Lab_screen_lock.sh ***'


echo "Set user template Require password after sleep or screen saver begins."
# -int 0 = off
# -int 1 = on
# -int 0 = default (off)
/usr/bin/defaults write /System/Library/User\ Template/Non_localized/Library/Preferences/com.apple.screensaver askForPassword -int 0

echo '*** End Set_Lab_screen_lock.sh ***'
exit 0
