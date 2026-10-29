#!/usr/bin/env python3
"""Install checksum-pinned Termux PRoot native dependencies.

Source URLs, versions, and SHA-256 values live in android_artifacts.lock.json.
The Termux repository package indexes and Alpine release checksums are the
sources for these pins. No executable is extracted to an Android noexec path:
all native executables are packaged through jniLibs for PackageManager.
Customized Alpine assets are managed separately by build_rootfs.py; this helper
never overwrites them with the original upstream minirootfs.
"""

import hashlib
import io
import json
import os
from pathlib import Path
import sys
import tarfile
import urllib.request

SCRIPT_DIR = Path(__file__).resolve().parent
PLUGIN_DIR = SCRIPT_DIR.parent
JNILIBS_DIR = PLUGIN_DIR / "android/src/main/jniLibs"
ASSETS_DIR = PLUGIN_DIR / "android/src/main/assets/shell"
LOCK = json.loads((SCRIPT_DIR / "android_artifacts.lock.json").read_text())
ARCH_CONFIG = {
    "arm64-v8a": ("aarch64", "aarch64", True),
    "x86_64": ("x86_64", "x86_64", True),
    "armeabi-v7a": ("arm", "armv7", False),
    "x86": ("i686", "x86", False),
}


def verified_download(url, expected_sha256):
    with urllib.request.urlopen(url, timeout=60) as response:
        data = response.read()
    actual = hashlib.sha256(data).hexdigest()
    if actual != expected_sha256:
        raise ValueError(f"SHA-256 mismatch for {url}: {actual}")
    return data


def extract_file_from_deb(deb_data, filename_suffix):
    """Read one regular member without extracting package paths to disk."""
    if not deb_data.startswith(b"!<arch>\n"):
        raise ValueError("Not a valid ar archive")
    offset = 8
    while offset < len(deb_data):
        header = deb_data[offset:offset + 60]
        if len(header) != 60:
            raise ValueError("Truncated ar header")
        name = header[:16].decode("ascii").strip().rstrip("/")
        size = int(header[48:58].decode("ascii").strip())
        offset += 60
        member_data = deb_data[offset:offset + size]
        if len(member_data) != size:
            raise ValueError("Truncated ar member")
        if name.startswith("data.tar"):
            with tarfile.open(fileobj=io.BytesIO(member_data), mode="r:*") as archive:
                matches = [member for member in archive if member.isfile()
                           and member.name.endswith(filename_suffix)]
                if len(matches) != 1:
                    raise ValueError(f"Expected one package member: {filename_suffix}")
                return archive.extractfile(matches[0]).read()
        offset += size + size % 2
    raise ValueError("Package is missing data.tar")


def write_asset(path, data, executable=False):
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(path.name + ".tmp")
    temporary.write_bytes(data)
    if executable:
        temporary.chmod(0o755)
    os.replace(temporary, path)
    print(f"Saved {path.relative_to(PLUGIN_DIR)} ({len(data)} bytes)")


def download_and_setup(archs=None):
    for arch in archs or ARCH_CONFIG:
        if arch not in ARCH_CONFIG:
            raise ValueError(f"Unknown architecture: {arch}")
        termux_arch, _, has_loader32 = ARCH_CONFIG[arch]
        packages = {}
        for name, package in LOCK["termux"][termux_arch].items():
            url = "https://packages.termux.dev/apt/termux-main/" + package["Filename"]
            packages[name] = verified_download(url, package["SHA256"])

        proot = extract_file_from_deb(packages["proot"], "bin/proot")
        original = b"libtalloc.so.2\x00"
        if proot.count(original) != 1:
            raise ValueError("Expected one libtalloc dependency in PRoot")
        proot = proot.replace(original, b"libtalloc.so\x00\x00\x00")
        binaries = {
            "libproot.so": proot,
            "libloader.so": extract_file_from_deb(packages["proot"], "libexec/proot/loader"),
            "libtalloc.so": extract_file_from_deb(packages["libtalloc"], "libtalloc.so.2.5.0"),
            "libandroid-shmem.so": extract_file_from_deb(packages["libandroid-shmem"], "lib/libandroid-shmem.so"),
        }
        if has_loader32:
            binaries["libloader32.so"] = extract_file_from_deb(packages["proot"], "libexec/proot/loader32")

        for name, data in binaries.items():
            write_asset(JNILIBS_DIR / arch / name, data, executable=True)


if __name__ == "__main__":
    download_and_setup(sys.argv[1:] or None)
