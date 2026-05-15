#!/bin/bash

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
# FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# Define the path to the script path sh file
SCRIPT_PATH="/usr/local/bin/connectsignin.sh"

# Create the script directory if it doesn't exist
if [ ! -d "/usr/local/bin" ]; then
    mkdir -p /usr/local/bin
fi

# Copy the script to $SCRIPT_PATH
cat <<'EOF' > "$SCRIPT_PATH"
#!/bin/bash
# Read PasswordCurrent value from com.jamf.connect.state plist
passwordCurrent=$(defaults read com.jamf.connect.state PasswordCurrent 2>/dev/null)

# If PasswordCurrent=0, execute open jamfconnect://signin
if [ "$passwordCurrent" -eq 0 ]; then
/usr/bin/open jamfconnect://signin
fi
EOF

# Set proper permissions for the script
chown root:wheel "$SCRIPT_PATH"
chmod 644 "$SCRIPT_PATH"

# Define the path to the LaunchAgent plist file
PLIST_PATH="/Library/LaunchAgents/com.jamf.connectsignin.plist"

# Create the LaunchAgents directory if it doesn't exist
if [ ! -d "/Library/LaunchAgents" ]; then
    mkdir -p /Library/LaunchAgents
fi

# Copy the plist file from the script's payload to the correct location
cat <<'EOF' > "$PLIST_PATH"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>KeepAlive</key>
		<false/>
		<key>Label</key>
		<string>com.jamf.connectsignin</string>
		<key>LimitLoadToSessionType</key>
		<array>
		<string>Aqua</string>
		</array>
		<key>ProgramArguments</key>
		<array>
		<string>/bin/bash</string>
		<string>/usr/local/bin/connectsignin.sh</string>
		</array>
		<key>StartInterval</key>
		<integer>900</integer>
		<key>RunAtLoad</key>
		<false/>
	</dict>
</plist>
EOF

# Set proper permissions for the LaunchAgent plist
chown root:wheel "$PLIST_PATH"
chmod 644 "$PLIST_PATH"

#Get Logged In User:
loggedInUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

#Get UID:
uid=$(/usr/bin/id -u "$loggedInUser")

# check if LA is loaded already
if /bin/launchctl asuser "$uid" launchctl list | grep -q "com.jamf.connectsignin"; then
	echo "$PLIST_PATH is already running for the logged-in user."
else
	echo "$PLIST_PATH is not running for the logged-in user. Loading launch agent.."
    #Load LA as that UID:
/bin/launchctl asuser "$uid" /usr/bin/sudo -u "$loggedInUser" /bin/launchctl load "$PLIST_PATH"
fi

exit 0