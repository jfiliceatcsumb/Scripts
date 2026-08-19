#!/bin/zsh

# Exit immediately if any command fails, treat unset variables as errors
set -e
set -u

# ==============================================================================
# CONFIGURATION & DISK IMAGE PATHS
# ==============================================================================
PKG_ID="com.apple.dt.Xcode"
MIN_OS_VERSION="12.0"

# Target installation path on the end-user's Mac
INSTALL_LOCATION="/Applications"

# Source path directly on the mounted disk image
SOURCE_VOLUME="/Volumes/Xcode app"
SOURCE_PAYLOAD="$SOURCE_VOLUME/Xcode.app"

# Optional: Developer ID Installer certificate string
DEVELOPER_ID_INSTALLER=""

# ==============================================================================
# VALIDATION & DYNAMIC VERSION EXTRACTION
# ==============================================================================
echo "Checking if Xcode volume is mounted..."
if [[ ! -d "$SOURCE_PAYLOAD" ]]; then
    echo "❌ Error: Xcode target not found at '$SOURCE_PAYLOAD'"
    echo "Please ensure the disk image is actively mounted at '$SOURCE_VOLUME'."
    exit 1
fi

echo "Extracting dynamic version information..."
# Read the short marketing version directly from Info.plist
PKG_VERSION=$(defaults read "$SOURCE_PAYLOAD/Contents/Info.plist" CFBundleShortVersionString)

if [[ -z "$PKG_VERSION" ]]; then
    echo "❌ Error: Could not parse version string from Info.plist."
    exit 1
fi
echo "--> Detected Xcode Version: $PKG_VERSION"

OUTPUT_NAME="Xcode_${PKG_VERSION}.pkg"

# ==============================================================================
# DIRECT COMPILATION (NO STAGING COPY)
# ==============================================================================
echo "Compiling native macOS package directly from source volume..."

# Zsh handles arrays explicitly without needing strict internal quoting rules during expansion
PKGBUILD_CMD=(
  pkgbuild
  --root "$SOURCE_VOLUME"
  --identifier "$PKG_ID"
  --version "$PKG_VERSION"
  --install-location "$INSTALL_LOCATION"
  --min-os-version "$MIN_OS_VERSION"
  --compression latest
  --large-payload
)

# Append code-signing identity if configured
if [[ -n "$DEVELOPER_ID_INSTALLER" ]]; then
    echo "Using signing certificate: $DEVELOPER_ID_INSTALLER"
    PKGBUILD_CMD+=(--sign "$DEVELOPER_ID_INSTALLER")
fi

# Append final package output path
PKGBUILD_CMD+=("./build/$OUTPUT_NAME")
mkdir -pv "./build/"
# Execute compilation natively. 
# Zsh safely expands "${PKGBUILD_CMD[@]}" or just $PKGBUILD_CMD preserving array items.
"${PKGBUILD_CMD[@]}"

echo "✅ Success! Generated direct-build package: ./build/$OUTPUT_NAME"
