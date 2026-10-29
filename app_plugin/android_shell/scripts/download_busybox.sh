#!/bin/bash
#
# Downloads busybox binaries from Termux package repository.
#
# Usage: ./download_busybox.sh
#
# This script downloads pre-compiled busybox binaries for all supported
# Android architectures from the Termux package repository.
#
# License: Busybox is GPL-licensed. Include the LICENSE file in distribution.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/../android/src/main/assets/shell"

# Termux package base URL
TERMUX_BASE="https://packages.termux.dev/apt/termux-main/pool/main/b/busybox"

# Package version (update this when newer version is available)
BUSYBOX_VERSION="1.36.1-4"

# Architecture mapping: Android ABI -> Termux arch
declare -A ARCH_MAP=(
    ["arm64-v8a"]="aarch64"
    ["armeabi-v7a"]="arm"
    ["x86_64"]="x86_64"
    ["x86"]="i686"
)

TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "Downloading busybox binaries from Termux repository..."
echo "Version: $BUSYBOX_VERSION"
echo "Destination: $ASSETS_DIR"
echo ""

for android_abi in "${!ARCH_MAP[@]}"; do
    termux_arch="${ARCH_MAP[$android_abi]}"
    deb_file="busybox_${BUSYBOX_VERSION}_${termux_arch}.deb"
    deb_url="${TERMUX_BASE}/${deb_file}"

    echo "Downloading $android_abi ($termux_arch)..."

    # Download .deb package
    if ! curl -sL -o "$TEMP_DIR/$deb_file" "$deb_url"; then
        echo "  Failed to download $deb_url"
        echo "  Trying alternative URL..."
        # Try without minor version
        deb_file="busybox_${BUSYBOX_VERSION%%-*}_${termux_arch}.deb"
        deb_url="${TERMUX_BASE}/${deb_file}"
        if ! curl -sL -o "$TEMP_DIR/$deb_file" "$deb_url"; then
            echo "  Failed! Skipping $android_abi"
            continue
        fi
    fi

    # Extract .deb (ar archive containing data.tar.xz)
    cd "$TEMP_DIR"
    if ! ar x "$deb_file" 2>/dev/null; then
        echo "  Failed to extract .deb archive"
        continue
    fi

    # Extract data.tar.xz
    if [ -f "data.tar.xz" ]; then
        tar xf data.tar.xz
    elif [ -f "data.tar.gz" ]; then
        tar xzf data.tar.gz
    elif [ -f "data.tar.zst" ]; then
        zstd -d data.tar.zst -o data.tar
        tar xf data.tar
    else
        echo "  Could not find data archive in .deb"
        continue
    fi

    # Find and copy busybox binary
    BUSYBOX_BIN=$(find . -name "busybox" -type f 2>/dev/null | head -1)
    if [ -n "$BUSYBOX_BIN" ]; then
        mkdir -p "$ASSETS_DIR/$android_abi"
        cp "$BUSYBOX_BIN" "$ASSETS_DIR/$android_abi/busybox"
        chmod +x "$ASSETS_DIR/$android_abi/busybox"
        echo "  Installed to $android_abi/busybox"
    else
        echo "  Could not find busybox binary in package"
    fi

    # Cleanup for next iteration
    rm -f *.tar* data.tar control.tar* debian-binary "$deb_file"
    rm -rf data
    cd - > /dev/null
done

echo ""
echo "Done! Binaries installed to: $ASSETS_DIR"
echo ""
echo "Binary sizes:"
for android_abi in "${!ARCH_MAP[@]}"; do
    if [ -f "$ASSETS_DIR/$android_abi/busybox" ]; then
        size=$(ls -lh "$ASSETS_DIR/$android_abi/busybox" | awk '{print $5}')
        echo "  $android_abi: $size"
    fi
done

echo ""
echo "IMPORTANT: Busybox is GPL-licensed."
echo "Include the LICENSE file when distributing."
echo ""
echo "To track these binaries with Git LFS, run:"
echo "  git lfs track 'app_plugin/android_shell/android/src/main/assets/shell/*/busybox'"
