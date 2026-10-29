#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python_framework="${1:-$script_dir/../ios/Frameworks/Python.xcframework}"
resources_path="${TARGET_BUILD_DIR:?}/${UNLOCALIZED_RESOURCES_FOLDER_PATH:?}"
frameworks_path="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH:?}"

case "${EFFECTIVE_PLATFORM_NAME:?}" in
  -iphoneos)
    slice="ios-arm64"
    supported_platform="iPhoneOS"
    ;;
  -iphonesimulator)
    slice="ios-arm64_x86_64-simulator"
    supported_platform="iPhoneSimulator"
    ;;
  *)
    echo "Unsupported Python platform: $EFFECTIVE_PLATFORM_NAME" >&2
    exit 1
    ;;
esac

mkdir -p "$resources_path/python/lib" "$frameworks_path"
rsync -a --delete --exclude 'libpython*.dylib' --exclude '__pycache__' --exclude '*.pyc' \
  "$python_framework/lib/" "$resources_path/python/lib/"
for architecture in ${ARCHS:?}; do
  architecture_lib="$python_framework/$slice/lib-$architecture"
  if [ ! -d "$architecture_lib" ]; then
    echo "Python support for $EFFECTIVE_PLATFORM_NAME/$architecture is missing" >&2
    exit 1
  fi
  rsync -a --exclude 'libpython*.dylib' --exclude '__pycache__' --exclude '*.pyc' \
    "$architecture_lib/" "$resources_path/python/lib/"
done

while IFS= read -r -d '' extension; do
  extension_name="$(basename "$extension")"
  module_name="${extension_name%%.*}"
  relative_extension="${extension#"$resources_path/"}"
  extension_framework="$frameworks_path/$module_name.framework"
  mkdir -p "$extension_framework"
  cp "$python_framework/build/iOS-dylib-Info-template.plist" "$extension_framework/Info.plist"
  plutil -replace CFBundleExecutable -string "$module_name" "$extension_framework/Info.plist"
  plutil -replace CFBundleIdentifier -string "${PRODUCT_BUNDLE_IDENTIFIER:?}.${module_name//_/-}" "$extension_framework/Info.plist"
  plutil -replace CFBundlePackageType -string FMWK "$extension_framework/Info.plist"
  plutil -replace CFBundleSupportedPlatforms -json "[\"$supported_platform\"]" "$extension_framework/Info.plist"

  binaries=()
  for architecture in $ARCHS; do
    binaries+=("$python_framework/$slice/lib-$architecture/${relative_extension#python/lib/}")
  done
  if [ "${#binaries[@]}" -eq 1 ]; then
    cp "${binaries[0]}" "$extension_framework/$module_name"
  else
    xcrun lipo -create "${binaries[@]}" -output "$extension_framework/$module_name"
  fi
  rm "$extension"
  printf 'Frameworks/%s.framework/%s\n' "$module_name" "$module_name" > "${extension%.so}.fwork"
  printf '%s\n' "${relative_extension%.so}.fwork" > "$extension_framework/$module_name.origin"

  privacy_file="$(dirname "$extension")/$module_name.xcprivacy"
  if [ -f "$privacy_file" ]; then
    cp "$privacy_file" "$extension_framework/PrivacyInfo.xcprivacy"
  fi
  if [ "${CODE_SIGNING_ALLOWED:-YES}" != NO ] && [ -n "${EXPANDED_CODE_SIGN_IDENTITY:-}" ]; then
    /usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" \
      --timestamp=none "$extension_framework"
  elif [ "$EFFECTIVE_PLATFORM_NAME" = -iphonesimulator ]; then
    /usr/bin/codesign --force --sign - --timestamp=none "$extension_framework"
  fi
done < <(find "$resources_path/python/lib" -name '*.so' -print0)

echo "Embedded Python standard library and extension frameworks for $ARCHS."
