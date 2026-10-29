#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
frameworks_dir="$script_dir/../ios/Frameworks"
python_release="3.14-b13"
archive="Python-3.14-iOS-support.b13.tar.gz"
checksum="ce1c68affa1cbd9c5611a0f4a013e412f14a760cf22c6bb58cfb4d893073bd45"
download_dir="$(mktemp -d)"
trap 'rm -rf "$download_dir"' EXIT

curl --fail --location --retry 2 \
  "https://github.com/beeware/Python-Apple-support/releases/download/$python_release/$archive" \
  --output "$download_dir/$archive"
printf '%s  %s\n' "$checksum" "$download_dir/$archive" | shasum -a 256 --check
tar -xzf "$download_dir/$archive" -C "$download_dir"
mkdir -p "$frameworks_dir/Python.xcframework"
rsync -a --delete "$download_dir/Python.xcframework/" "$frameworks_dir/Python.xcframework/"
echo "Installed CPython 3.14.9 ($python_release) with standard library and iOS support files."
