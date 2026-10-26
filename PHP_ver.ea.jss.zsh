#!/bin/zsh --no-rcs
# 
# Jason Filice
# jfilice@csumb.edu
# Technology Support Services in IT
# California State University, Monterey Bay
# https://csumb.edu/it

# All discovered versions and their respective paths are aggregated into a clean, comma-separated list formatted as [Version] at [Path]. 
# If multiple versions exist, they are separated by a newline character within the single <result> tag block.
# If no PHP binaries are found, it gracefully outputs <result>None</result>

# search_paths
# "/opt/homebrew/bin/php"
# "/opt/homebrew/opt/php*/bin/php"
# "/usr/local/bin/php"
# "/usr/local/opt/php*/bin/php"
# "/Applications/MAMP/bin/php/php*/bin/php"
# "/Applications/Herd.app/Contents/Resources/valet/bin/php*"
# "$HOME/.config/herd/bin/php*"
# "$HOME/.asdf/shims/php"
# "$HOME/.jenv/shims/php"
# 


# Array to track unique real paths and prevent duplicates (e.g., symlinks)
typeset -A SEEN_PATHS
RESULT_STRING=""

# Function to check a PHP binary, extract version, and add to results
check_php_binary() {
    local php_path="$1"
    
    # Verify the file exists and is executable
    [[ -x "$php_path" ]] || return

    # Resolve the absolute real path to filter out duplicate symlinks
    local real_path
    real_path=$(zmodload zsh/stat &>/dev/null && stat +link "$php_path" 2>/dev/null || readlink -f "$php_path" 2>/dev/null)
    [[ -z "$real_path" ]] && real_path="$php_path"

    # Skip if we already evaluated this exact binary
    [[ -n "${SEEN_PATHS[$real_path]}" ]] && return
    SEEN_PATHS[$real_path]=1

    # Extract version string safely
    local version
    version=$("$php_path" -r 'echo PHP_VERSION;' 2>/dev/null)

    if [[ -n "$version" ]]; then
        if [[ -z "$RESULT_STRING" ]]; then
            RESULT_STRING="${version} at ${php_path}"
        else
            RESULT_STRING="${RESULT_STRING}\n${version} at ${php_path}"
        fi
    fi
}

# 1. Native macOS (macOS 11 Big Sur and older)
check_php_binary "/usr/bin/php"

# 2. Managed & Open Source Homebrew Ecosystem (Workbrew, Apple Silicon, & Intel)
for brew_prefix in "/opt/workbrew" "/opt/homebrew" "/usr/local"; do
    if [[ -d "$brew_prefix" ]]; then
        # Default active php link under this prefix
        check_php_binary "$brew_prefix/bin/php"
        
        # Version-pinned links (e.g., /opt/workbrew/opt/php@8.3/bin/php)
        for pin in $brew_prefix/opt/php@*/bin/php(N); do
            check_php_binary "$pin"
        done
    fi
done

# 3. MacPorts
if [[ -d "/opt/local/bin" ]]; then
    check_php_binary "/opt/local/bin/php"
    for port_bin in /opt/local/bin/php[0-9]#(N); do
        check_php_binary "$port_bin"
    done
fi

# 4. Fink
if [[ -d "/sw/bin" ]]; then
    check_php_binary "/sw/bin/php"
    for fink_bin in /sw/bin/php[0-9.]#(N); do
        check_php_binary "$fink_bin"
    done
fi

# 5. MAMP
if [[ -d "/Applications/MAMP/bin" ]]; then
    check_php_binary "/Applications/MAMP/bin/php"
    for mamp_bin in /Applications/MAMP/bin/php/php[0-9.]#(N); do
        check_php_binary "$mamp_bin"
    done
fi


# 6. Herd
if [[ -d "/Applications/Herd.app/Contents/Resources/valet/bin" ]]; then
    check_php_binary "/Applications/Herd.app/Contents/Resources/valet/bin/php"
    for herd_bin in /Applications/Herd.app/Contents/Resources/valet/bin/php[0-9.]#(N); do
        check_php_binary "$herd_bin"
    done
fi



# 7. Environment PATH Fallback (for any custom or user-level installations)
if (( $+commands[php] )); then
    check_php_binary "$commands[php]"
fi


# Format output for Jamf Pro
if [[ -n "$RESULT_STRING" ]]; then
    echo "<result>${RESULT_STRING}</result>"
else
    echo "<result>None</result>"
fi

exit 0