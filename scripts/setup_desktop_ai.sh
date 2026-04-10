#!/bin/bash
# Helper script to set up desktop AI after manual download
# Usage: ./scripts/setup_desktop_ai.sh

set -e

APP_BUNDLE="build/macos/Build/Products/Debug/gsmlg.app"
RESOURCES="$APP_BUNDLE/Contents/Resources"
FRAMEWORKS="$APP_BUNDLE/Contents/Frameworks"
JAR_CACHE="$HOME/Library/Caches/flutter_gemma/jar"

echo "=== Desktop AI Setup Helper ==="
echo ""
echo "If downloads are timing out, you can manually download:"
echo "1. litertlm-server.jar:"
echo "   https://github.com/DenisovAV/flutter_gemma/releases/download/v0.13.1/litertlm-server.jar"
echo ""
echo "Place the downloaded JAR in: $JAR_CACHE/"
echo "Then run this script again."
echo ""

# Check if JAR exists in cache
if [[ -f "$JAR_CACHE/litertlm-server.jar" ]]; then
    echo "✓ Found cached JAR"

    # Verify JAR is valid
    if unzip -t "$JAR_CACHE/litertlm-server.jar" >/dev/null 2>&1; then
        echo "✓ JAR is valid"

        # Copy to app bundle
        cp "$JAR_CACHE/litertlm-server.jar" "$RESOURCES/"
        echo "✓ Copied JAR to app bundle"

        # Extract native libraries
        NATIVES_DIR="$FRAMEWORKS/litertlm"
        rm -rf "$NATIVES_DIR"
        mkdir -p "$NATIVES_DIR"

        unzip -o "$RESOURCES/litertlm-server.jar" "com/google/ai/edge/litertlm/jni/darwin-aarch64/*" -d /tmp/litertlm_extract/ >/dev/null 2>&1
        find /tmp/litertlm_extract/com/google/ai/edge/litertlm/jni/darwin-aarch64/ -type f -name "*.so" -exec cp {} "$NATIVES_DIR/" \; 2>/dev/null || true

        # Remove quarantine and sign
        xattr -r -d com.apple.quarantine "$NATIVES_DIR" 2>/dev/null || true
        find "$NATIVES_DIR" -type f -name "*.so" -exec codesign --force --sign - {} \; 2>/dev/null || true

        rm -rf /tmp/litertlm_extract

        echo "✓ Native libraries extracted and signed"
        echo ""
        echo "=== Setup Complete! ==="
        echo "You can now run: flutter run -d macos"
        exit 0
    else
        echo "✗ JAR is corrupted. Please delete and re-download:"
        echo "   rm $JAR_CACHE/litertlm-server.jar"
        exit 1
    fi
else
    echo "✗ JAR not found in cache"
    echo ""
    echo "To download manually:"
    echo "  mkdir -p $JAR_CACHE"
    echo "  cd $JAR_CACHE"
    echo "  curl -LO https://github.com/DenisovAV/flutter_gemma/releases/download/v0.13.1/litertlm-server.jar"
    echo ""
    echo "Then run this script again."
    exit 1
fi
