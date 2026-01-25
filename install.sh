#!/bin/bash
# ZDragon macOS Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/Baudin999/zdragon-releases/master/install.sh | bash

set -e

REPO="Baudin999/zdragon-releases"
APP_NAME="zdragon"
INSTALL_DIR="/Applications"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}==>${NC} $1"; }
success() { echo -e "${GREEN}==>${NC} $1"; }
warn() { echo -e "${YELLOW}==>${NC} $1"; }
error() { echo -e "${RED}Error:${NC} $1"; exit 1; }

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    error "This installer is for macOS only. Please download the appropriate version from:
    https://github.com/$REPO/releases"
fi

# Detect architecture
ARCH="$(uname -m)"
if [[ "$ARCH" == "arm64" ]]; then
    ASSET_NAME="zdragon_darwin_arm64.zip"
elif [[ "$ARCH" == "x86_64" ]]; then
    warn "Intel Mac detected. Currently only Apple Silicon builds are available."
    warn "You may need to use Rosetta 2 or build from source."
    ASSET_NAME="zdragon_darwin_arm64.zip"
else
    error "Unsupported architecture: $ARCH"
fi

info "ZDragon Installer for macOS"
echo ""

# Get latest release info
info "Fetching latest release..."
RELEASE_JSON=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest") || error "Failed to fetch release info"

VERSION=$(echo "$RELEASE_JSON" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
DOWNLOAD_URL=$(echo "$RELEASE_JSON" | grep "browser_download_url.*$ASSET_NAME" | sed -E 's/.*"([^"]+)".*/\1/')

if [[ -z "$DOWNLOAD_URL" ]]; then
    error "Could not find download URL for $ASSET_NAME"
fi

info "Latest version: $VERSION"
echo ""

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Download
info "Downloading $ASSET_NAME..."
curl -fSL --progress-bar "$DOWNLOAD_URL" -o "$TEMP_DIR/$ASSET_NAME" || error "Download failed"

# Extract
info "Extracting..."
unzip -q "$TEMP_DIR/$ASSET_NAME" -d "$TEMP_DIR" || error "Extraction failed"

# Find the .app bundle
APP_BUNDLE=$(find "$TEMP_DIR" -name "*.app" -maxdepth 2 -type d | head -1)
if [[ -z "$APP_BUNDLE" ]]; then
    error "Could not find .app bundle in archive"
fi

APP_BASENAME=$(basename "$APP_BUNDLE")

# Remove existing installation
if [[ -d "$INSTALL_DIR/$APP_BASENAME" ]]; then
    warn "Removing existing installation..."
    rm -rf "$INSTALL_DIR/$APP_BASENAME"
fi

# Move to Applications
info "Installing to $INSTALL_DIR..."
mv "$APP_BUNDLE" "$INSTALL_DIR/" || error "Failed to move app to $INSTALL_DIR (try running with sudo)"

# Remove quarantine attribute (this is the key fix for Gatekeeper)
info "Removing quarantine attribute..."
xattr -cr "$INSTALL_DIR/$APP_BASENAME" 2>/dev/null || true

echo ""
success "ZDragon $VERSION installed successfully!"
echo ""
echo "You can now:"
echo "  1. Open ZDragon from your Applications folder"
echo "  2. Or run: open '$INSTALL_DIR/$APP_BASENAME'"
echo ""
info "To uninstall, simply delete '$INSTALL_DIR/$APP_BASENAME'"
