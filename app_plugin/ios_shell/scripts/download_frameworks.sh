#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
frameworks_dir="$script_dir/../ios/Frameworks"
resources_dir="$script_dir/../ios/Resources"
download_dir="$(mktemp -d "${TMPDIR:-/tmp}/ios-shell-frameworks.XXXXXX")"
trap 'rm -rf "$download_dir"' EXIT
mkdir -p "$download_dir/Frameworks"

download_verified() {
  local url="$1" checksum="$2" destination="$3"
  local cached_file="${IOS_SHELL_ARCHIVE_CACHE:-}/$(basename "$url")"
  if [ -n "${IOS_SHELL_ARCHIVE_CACHE:-}" ] && [ -f "$cached_file" ]; then
    cp "$cached_file" "$destination"
  else
    curl --fail --location --retry 2 "$url" --output "$destination"
  fi
  printf '%s  %s\n' "$checksum" "$destination" | shasum -a 256 --check
}

framework_names=()
while IFS='|' read -r framework url checksum normalize; do
  archive="$download_dir/$framework.zip"
  echo "Preparing $framework..."
  download_verified "$url" "$checksum" "$archive"
  unzip -q "$archive" -d "$download_dir/Frameworks"
  if [ "$normalize" = ios ]; then
    python3 "$script_dir/normalize_xcframework.py" "$download_dir/Frameworks/$framework.xcframework"
  fi
  framework_names+=("$framework")
done <<'FRAMEWORKS'
ios_system|https://github.com/holzschu/ios_system/releases/download/v3.0.4/ios_system.xcframework.zip|6973c1c14a66cdc110a5be7d62991af4546124bd0d9773b5391694b3a93a5be0|all
shell|https://github.com/holzschu/ios_system/releases/download/v3.0.4/shell.xcframework.zip|78d71828b89c83741a8f7e857f0d065da72952558fd7deb806f5748c3801fd95|all
files|https://github.com/holzschu/ios_system/releases/download/v3.0.4/files.xcframework.zip|02d6522f5e1adc3b472f7aaa53910f049e6c5829e07c7e3005cf2a0d5f9f423a|all
text|https://github.com/holzschu/ios_system/releases/download/v3.0.4/text.xcframework.zip|2450f309d0793490136a24f9af02c42fb712b327571cb44312fe330e87a156f2|all
tar|https://github.com/holzschu/ios_system/releases/download/v3.0.4/tar.xcframework.zip|9bf482b29ea95bc643bfaa06b249394afed188e40482db055625f4928ffedc48|all
awk|https://github.com/holzschu/ios_system/releases/download/v3.0.4/awk.xcframework.zip|6898b01913261eee194edcb464212d4af6bc33355b1e286bbbd17f3f878c1706|all
curl_ios|https://github.com/holzschu/ios_system/releases/download/v3.0.4/curl_ios.xcframework.zip|2a0020ce4904ea71e83c8daa86e99515b322981abc8ab2092b700661bcc880cd|ios
libssh2|https://github.com/holzschu/libssh2-apple/releases/download/v1.11.0/libssh2-dynamic.xcframework.zip|cacfe1789b197b727119f7e32f561eaf9acc27bf38cd19975b74fce107f868a6|ios
openssl|https://github.com/holzschu/openssl-apple/releases/download/v1.1.1w/openssl-dynamic.xcframework.zip|329e8317cf9bee8e138da5d032330a7a1bd2473cf44c9c083cb2f0636abb8b80|ios
network_ios|https://github.com/holzschu/network_ios/releases/download/v0.2/network_ios.xcframework.zip|18e96112ae86ec39390487d850e7732d88e446f9f233b2792d633933d4606d46|ios
lua_ios|https://github.com/holzschu/lua_ios/releases/download/1.0/lua_ios.xcframework.zip|0ccdab671f31c20daf8833452cc36598b49f84441851d7142b305443425bc527|ios
lg2|https://github.com/holzschu/libgit2/releases/download/ios_1.0/lg2.xcframework.zip|7d205a771be8d120a80d2f7281135dfffd21a3713c86eb4f1957638f6b4b365e|ios
FRAMEWORKS

python3 "$script_dir/build_lg2_simulator.py" --frameworks-dir "$download_dir/Frameworks"
download_verified https://curl.se/ca/cacert-2026-10-20.pem \
  796f1389bfea13c0ed78f663b765baaff54a508e5483786bd6ece73c5e3e3cbe \
  "$download_dir/cacert.pem"
bash "$script_dir/download_python.sh"

mkdir -p "$frameworks_dir" "$resources_dir"
for framework in "${framework_names[@]}"; do
  mkdir -p "$frameworks_dir/$framework.xcframework"
  rsync -a --delete "$download_dir/Frameworks/$framework.xcframework/" "$frameworks_dir/$framework.xcframework/"
done
cp "$download_dir/cacert.pem" "$resources_dir/cacert.pem"
echo "Installed iOS shell frameworks, Python runtime, and pinned CA certificates."
