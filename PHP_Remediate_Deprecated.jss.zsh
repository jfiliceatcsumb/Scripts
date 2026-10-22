#!/bin/zsh --no-rcs
# 
# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it

# Ensure the script is running with root privileges
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root by Jamf Pro."
    exit 1
fi

# Target current user console to correctly invoke user-space Homebrew environments
CURRENT_USER=$(stat -f '%Su' /dev/console)
USER_HOME=$(dscl . -read "/Users/$CURRENT_USER" NFSHomeDirectory | awk '{print $2}')

# Arrays to target specific End-Of-Life (EOL) versions
DEPRECATED_BREW_PACKAGES=("php@7.1" "php@7.2" "php@7.3" "php@7.4" "php@8.0")
DEPRECATED_PORTS=("php56" "php70" "php71" "php72" "php73" "php74" "php80")

echo "Starting PHP remediation cleanup for active user: $CURRENT_USER"

# -------------------------------------------------------------------------
# 1. REMOVE DEPRECATED HOMEBREW PACKAGES
# -------------------------------------------------------------------------
# Homebrew must be executed in the context of the logged-in user
for BREW_PREFIX in "/opt/homebrew/bin/brew" "/usr/local/bin/brew"; do
    if [[ -x "$BREW_PREFIX" ]]; then
        echo "Found Homebrew at $BREW_PREFIX. Checking for deprecated packages..."
        
        for pkg in "${DEPRECATED_BREW_PACKAGES[@]}"; do
            if sudo -u "$CURRENT_USER" HOME="$USER_HOME" "$BREW_PREFIX" list --formula | grep -q "^${pkg}$"; then
                echo "Removing outdated Homebrew package: $pkg"
                sudo -u "$CURRENT_USER" HOME="$USER_HOME" "$BREW_PREFIX" uninstall --force "$pkg"
            fi
        done
        
        # Clean up unneeded build leftovers and cached files
        sudo -u "$CURRENT_USER" HOME="$USER_HOME" "$BREW_PREFIX" cleanup -s
    fi
done

# -------------------------------------------------------------------------
# 2. REMOVE DEPRECATED MACPORTS PACKAGES
# -------------------------------------------------------------------------
if [[ -x "/opt/local/bin/port" ]]; then
    echo "Found MacPorts. Checking for legacy installations..."
    
    for port_name in "${DEPRECATED_PORTS[@]}"; do
        if /opt/local/bin/port installed | grep -q "${port_name}"; then
            echo "Uninstalling legacy MacPort: $port_name"
            /opt/local/bin/port uninstall --follow-dependencies "$port_name"
        fi
    done
    
    # Clean up empty or broken variants left behind
    /opt/local/bin/port clean --all inactive
fi

# -------------------------------------------------------------------------
# 3. PURGE STALE SYSTEM AND USER CONFIG SYMLINKS
# -------------------------------------------------------------------------
echo "Scanning structural symlinks for dead references..."

# If the default Homebrew alias points to a legacy version, unbind it
for ALIAS_PATH in "/opt/homebrew/bin/php" "/usr/local/bin/php"; do
    if [[ -L "$ALIAS_PATH" ]]; then
        REAL_TARGET=$(readlink "$ALIAS_PATH")
        if [[ "$REAL_TARGET" =~ "php@(7\.|8\.0)" ]]; then
            echo "Removing default alias pointing to deprecated runtime: $ALIAS_PATH"
            rm "$ALIAS_PATH"
        fi
    fi
done

echo "PHP Remediation steps complete."

# Force a recon inventory collection so Jamf registers the drop from the Smart Group
echo "Triggering immediate Jamf inventory update..."
/usr/local/jamf/bin/jamf recon

exit 0
