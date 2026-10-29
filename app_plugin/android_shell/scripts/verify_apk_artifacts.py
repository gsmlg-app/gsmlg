#!/usr/bin/env python3
"""Verify the packaged Android shell launch contract without running the APK."""

import argparse
from collections import Counter
import hashlib
from pathlib import Path
import struct
import tempfile
from zipfile import ZipFile

from build_rootfs import verify_assets
from setup_alpine_proot import ARCH_CONFIG
from test_android_artifacts import needed_libraries

FLUTTER_ABIS = {
    'arm64-v8a': (2, 183),
    'armeabi-v7a': (1, 40),
    'x86_64': (2, 62),
}
SYSTEM_LIBRARIES = {
    'libc.so', 'libdl.so', 'libm.so', 'liblog.so', 'libandroid.so',
    'libEGL.so', 'libGLESv2.so', 'libjnigraphics.so',
}


def verify_apk(apk):
    lock = verify_assets()
    with ZipFile(apk) as archive:
        names = archive.namelist()
        duplicates = [name for name, count in Counter(names).items() if count > 1]
        if duplicates:
            raise ValueError(f'Duplicate APK entries: {duplicates}')
        bad_member = archive.testzip()
        if bad_member:
            raise ValueError(f'APK CRC check failed: {bad_member}')
        config_name = 'assets/shell/rootfs-config.json'
        if config_name not in names:
            raise ValueError('Missing runtime rootfs configuration')
        config_hash = hashlib.sha256(archive.read(config_name)).hexdigest()
        if config_hash != lock['configSha256']:
            raise ValueError('Packaged rootfs configuration does not match the image lock')
        for abi in ARCH_CONFIG:
            name = f'assets/shell/{abi}/rootfs.tgz'
            stale = [f'assets/shell/{abi}/{suffix}'
                     for suffix in ('rootfs.tar', 'rootfs.tar.gz')
                     if f'assets/shell/{abi}/{suffix}' in names]
            if stale:
                raise ValueError(f'Stale rootfs asset paths: {stale}')
            if name not in names:
                raise ValueError(f'Missing runtime rootfs asset: {name}')
            data = archive.read(name)
            expected = lock['architectures'][abi]['sha256']
            if not data.startswith(b'\x1f\x8b') or hashlib.sha256(data).hexdigest() != expected:
                raise ValueError(f'Rootfs gzip bytes do not match the locked customized image: {name}')
            print(f'PASS customized rootfs: {name}')
        for abi, architecture in FLUTTER_ABIS.items():
            prefix = f'lib/{abi}/'
            libraries = {name.removeprefix(prefix): name for name in names
                         if name.startswith(prefix) and name.endswith('.so')}
            required = {'libapp.so', 'libflutter.so', 'libflutter_pty.so', 'libproot.so',
                        'libloader.so', 'libtalloc.so', 'libandroid-shmem.so'}
            if ARCH_CONFIG[abi][2]:
                required.add('libloader32.so')
            if missing := required - libraries.keys():
                raise ValueError(f'Missing native libraries for {abi}: {sorted(missing)}')
            for library, name in sorted(libraries.items()):
                try:
                    data = archive.read(name)
                    if data[:4] != b'\x7fELF' or data[5:6] != b'\x01':
                        raise ValueError('Expected a little-endian ELF binary')
                    elf_class = data[4]
                    machine = struct.unpack_from('<H', data, 18)[0]
                    with tempfile.TemporaryDirectory() as temporary:
                        binary = Path(temporary) / library
                        binary.write_bytes(data)
                        needed = set(needed_libraries(binary))
                except (ValueError, IndexError, StopIteration, struct.error) as error:
                    raise ValueError(f'Invalid packaged ELF {name}: {error}') from error
                expected_architecture = architecture
                if library == 'libloader32.so':
                    expected_architecture = (1, 40 if abi == 'arm64-v8a' else 3)
                if (elf_class, machine) != expected_architecture:
                    raise ValueError(f'Wrong ELF architecture for {name}: {(elf_class, machine)}')
                if missing := needed - libraries.keys() - SYSTEM_LIBRARIES:
                    raise ValueError(f'Unpackaged dependencies of {name}: {sorted(missing)}')
            print(f'PASS {abi}: {len(libraries)} ELF binaries with complete dependencies')
    print(f'PASS APK shell launch contract: {apk}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('apk', type=Path)
    args = parser.parse_args()
    try:
        verify_apk(args.apk)
    except (OSError, ValueError, KeyError) as error:
        parser.exit(1, f'APK verification failed: {error}\n')
