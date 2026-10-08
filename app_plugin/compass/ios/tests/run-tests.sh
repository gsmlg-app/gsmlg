#!/usr/bin/env bash
set -euo pipefail

# Runs the real Swift source against UIKit/CoreLocation on an already booted iOS simulator.
test_directory="$(cd "$(dirname "$0")" && pwd)"
flutter_executable="$(command -v flutter)"
flutter_root="$(dirname "$(dirname "$(realpath "$flutter_executable")")")"
framework_directory="$flutter_root/bin/cache/artifacts/engine/ios/Flutter.xcframework/ios-arm64_x86_64-simulator"
sdk_directory="$(xcrun --sdk iphonesimulator --show-sdk-path)"
output_directory="$(mktemp -d /tmp/app-compass-tests.XXXXXX)"
trap 'rm -rf "$output_directory"' EXIT

xcrun --sdk iphonesimulator swiftc \
    -target "$(uname -m)-apple-ios17.0-simulator" \
    -sdk "$sdk_directory" \
    -F "$framework_directory" \
    -framework Flutter \
    -Xlinker -rpath -Xlinker "$framework_directory" \
    "$test_directory/../app_compass/Sources/app_compass/CompassPlugin.swift" \
    "$test_directory/CompassHeadingTests.swift" \
    -o "$output_directory/CompassHeadingTests"

xcrun simctl spawn booted "$output_directory/CompassHeadingTests"
