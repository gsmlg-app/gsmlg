#!/bin/bash
# LiteRT-LM Desktop Setup - Post-build script
# Copies JRE, JAR, and native libraries into the app bundle.
# Designed to run as the LAST build phase so that Xcode's implicit
# code-signing step does not corrupt the JRE binaries.
#
# Usage: setup_litertlm.sh <APP_BUNDLE>

set -e

APP_BUNDLE="${1:-}"

if [[ -z "$APP_BUNDLE" || ! -d "$APP_BUNDLE" ]]; then
    echo "warning: No valid app bundle: $APP_BUNDLE"
    exit 0
fi

echo "=== LiteRT-LM Setup ==="
echo "App bundle: $APP_BUNDLE"

RESOURCES="$APP_BUNDLE/Contents/Resources"
FRAMEWORKS="$APP_BUNDLE/Contents/Frameworks"
JRE_CACHE="$HOME/Library/Caches/flutter_gemma/jre"
JAR_CACHE="$HOME/Library/Caches/flutter_gemma/jar"
ARCH=$(uname -m)

# --- JRE ---
JRE_DEST="$RESOURCES/jre"
JRE_DIR="$JRE_CACHE/zulu24.32.13-ca-jre24.0.2-macosx_aarch64"

if [[ "$ARCH" != "arm64" ]]; then
    echo "warning: LiteRT-LM requires Apple Silicon (arm64)"
    exit 0
fi

# Always re-copy JRE from cache to undo Xcode's implicit re-signing
# which corrupts the hardened-runtime signature from Azul.
if [[ -d "$JRE_DIR" ]]; then
    echo "Copying JRE from cache..."
    rm -rf "$JRE_DEST"
    mkdir -p "$JRE_DEST"
    cp -a "$JRE_DIR/"* "$JRE_DEST/"
    echo "JRE installed"
else
    # Try downloading via the plugin's setup script as fallback
    echo "warning: JRE not found in cache at $JRE_DIR"
    echo "  Run the flutter_gemma setup_desktop.sh script once to download it:"
    echo "  Or download Azul Zulu JRE 24 to $JRE_CACHE/"
    exit 0
fi

# Verify java works
if ! "$JRE_DEST/bin/java" -version >/dev/null 2>&1; then
    echo "warning: Bundled java binary not working, attempting ad-hoc re-sign..."
    # Sign all Mach-O files with simple ad-hoc signature
    find "$JRE_DEST" -type f \( -name "*.dylib" -o -perm +111 \) | while read f; do
        if file -b "$f" 2>/dev/null | grep -q "Mach-O"; then
            codesign --force --sign - "$f" 2>/dev/null || true
        fi
    done
    if ! "$JRE_DEST/bin/java" -version >/dev/null 2>&1; then
        echo "error: Java still not working after re-sign"
        exit 1
    fi
    echo "Java working after re-sign"
fi

# --- JAR ---
JAR_DEST="$RESOURCES/litertlm-server.jar"
JAR_MIN_SIZE=1000000  # Real JAR is ~133 MB; LFS pointer is ~134 bytes

jar_valid=false
if [[ -f "$JAR_DEST" ]]; then
    jar_size=$(stat -f%z "$JAR_DEST" 2>/dev/null || echo 0)
    if [[ "$jar_size" -gt "$JAR_MIN_SIZE" ]]; then
        jar_valid=true
    else
        echo "JAR in bundle is too small (${jar_size} bytes) — likely a Git LFS pointer, replacing..."
        rm -f "$JAR_DEST"
    fi
fi

if [[ "$jar_valid" == false ]]; then
    JAR_SRC="$JAR_CACHE/litertlm-server.jar"
    if [[ -f "$JAR_SRC" ]]; then
        jar_src_size=$(stat -f%z "$JAR_SRC" 2>/dev/null || echo 0)
        if [[ "$jar_src_size" -gt "$JAR_MIN_SIZE" ]]; then
            echo "Copying JAR from cache..."
            cp "$JAR_SRC" "$JAR_DEST"
        else
            echo "warning: cached JAR is too small (${jar_src_size} bytes), skipping"
        fi
    fi

    # Download if still missing
    if [[ ! -f "$JAR_DEST" ]]; then
        JAR_VERSION="0.13.1"
        JAR_URL="https://github.com/DenisovAV/flutter_gemma/releases/download/v${JAR_VERSION}/litertlm-server.jar"
        echo "Downloading JAR from $JAR_URL..."
        mkdir -p "$JAR_CACHE"
        if curl -L -o "$JAR_CACHE/litertlm-server.jar" "$JAR_URL" --fail --retry 3 --progress-bar; then
            cp "$JAR_CACHE/litertlm-server.jar" "$JAR_DEST"
            echo "JAR downloaded and installed"
        else
            echo "warning: Failed to download litertlm-server.jar"
        fi
    fi
else
    echo "JAR already in bundle"
fi

# --- Native libraries ---
NATIVES_DIR="$FRAMEWORKS/litertlm"
if ! ls "$NATIVES_DIR"/*.so 1>/dev/null 2>&1; then
    if [[ -f "$JAR_DEST" ]]; then
        echo "Extracting native libraries..."
        NATIVE_PATH="com/google/ai/edge/litertlm/jni/darwin-aarch64"
        TEMP=$(mktemp -d)
        unzip -o "$JAR_DEST" "$NATIVE_PATH/*" -d "$TEMP" 2>/dev/null || true
        if [[ -d "$TEMP/$NATIVE_PATH" ]]; then
            rm -rf "$NATIVES_DIR"
            mkdir -p "$NATIVES_DIR"
            find "$TEMP/$NATIVE_PATH" -type f \( -name "*.so" -o -name "*.dylib" \) -exec cp {} "$NATIVES_DIR/" \;
            # Sign native libs
            find "$NATIVES_DIR" -type f \( -name "*.so" -o -name "*.dylib" \) -exec codesign --force --sign - {} \;
            echo "Native libraries extracted and signed"
        fi
        rm -rf "$TEMP"
    fi
else
    echo "Native libraries already in bundle"
fi

echo "=== LiteRT-LM Setup Complete ==="
