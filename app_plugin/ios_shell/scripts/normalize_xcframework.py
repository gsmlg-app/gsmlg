#!/usr/bin/env python3
import argparse
import plistlib
import shutil
from pathlib import Path


def normalize(framework):
    metadata_file = framework / 'Info.plist'
    metadata = plistlib.loads(metadata_file.read_bytes())
    libraries = metadata['AvailableLibraries']
    selected = [
        library for library in libraries
        if library['SupportedPlatform'] == 'ios'
        and library.get('SupportedPlatformVariant') in (None, 'simulator')
    ]
    if not selected:
        raise ValueError(f'No iOS libraries found in {framework}')
    for library in selected:
        library_path = framework / library['LibraryIdentifier'] / library['LibraryPath']
        info = plistlib.loads((library_path / 'Info.plist').read_bytes())
        binary = library_path / info['CFBundleExecutable']
        with binary.open('rb') as executable:
            magic = executable.read(4)
        if magic not in (
            b'\xfe\xed\xfa\xce', b'\xce\xfa\xed\xfe',
            b'\xfe\xed\xfa\xcf', b'\xcf\xfa\xed\xfe',
            b'\xca\xfe\xba\xbe', b'\xbe\xba\xfe\xca',
            b'\xca\xfe\xba\xbf', b'\xbf\xba\xfe\xca',
        ):
            raise ValueError(f'Framework executable is not Mach-O: {binary}')
    retained = {library['LibraryIdentifier'] for library in selected}
    for library in libraries:
        identifier = library['LibraryIdentifier']
        if identifier not in retained:
            shutil.rmtree(framework / identifier)
    metadata['AvailableLibraries'] = selected
    metadata_file.write_bytes(plistlib.dumps(metadata))


def main():
    parser = argparse.ArgumentParser(description='Keep actual iOS device/simulator XCFramework slices.')
    parser.add_argument('framework', type=Path)
    arguments = parser.parse_args()
    normalize(arguments.framework)


if __name__ == '__main__':
    main()
