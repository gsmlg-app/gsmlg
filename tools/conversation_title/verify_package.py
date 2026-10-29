#!/usr/bin/env python3
"""Audit a built .app/bundle directory, APK, IPA, ZIP or tar.gz offline."""
import argparse
import hashlib
import json
from pathlib import Path
import tarfile
import zipfile

MANIFEST = json.loads(Path(__file__).with_name('model.json').read_text())


def audit(entries):
    entries = [(name.replace('\\', '/'), read) for name, read in entries]
    weights = [(n, read) for n, read in entries if n.endswith('/' + MANIFEST['filename'])]
    if len(weights) != 1:
        raise ValueError(f'Expected exactly one bundled title model; found {len(weights)}')
    name, read = weights[0]
    digest = hashlib.sha256()
    size = 0
    with read() as source:
        while data := source.read(1024 * 1024):
            digest.update(data)
            size += len(data)
    if size != MANIFEST['size'] or digest.hexdigest() != MANIFEST['sha256']:
        raise ValueError('Packaged model size or SHA-256 mismatch')
    names = {n for n, _ in entries}
    for notice in ['LICENSE', 'NOTICE']:
        if name.rsplit('/', 1)[0] + '/' + notice not in names:
            raise ValueError(f'Missing packaged model {notice}')
    native = any('lib_llama_cpp' in n and n.endswith(('.so', '.dll', '.dylib', '/lib_llama_cpp_macos', '/lib_llama_cpp_ios')) for n in names)
    if not native:
        # A statically linked iOS framework must export the engine for dlsym.
        for n, read in entries:
            if n.endswith('/Runner') or n == 'Runner':
                with read() as source:
                    previous = b''
                    while block := source.read(1024 * 1024):
                        if b'llcs_engine_create' in previous + block:
                            native = True
                            break
                        previous = block[-64:]
    if not native:
        raise ValueError('Packaged llama.cpp native library or exported iOS engine not found')
    print(f'Verified {name}: {size} bytes, SHA-256 {digest.hexdigest()}')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('package', type=Path)
    path = parser.parse_args().package
    if path.is_dir():
        audit([(str(p.relative_to(path)), lambda p=p: p.open('rb')) for p in path.rglob('*') if p.is_file()])
    elif zipfile.is_zipfile(path):
        with zipfile.ZipFile(path) as archive:
            if path.suffix == '.aab':
                manifest = archive.read('conversation_title/manifest/AndroidManifest.xml')
                if b'install-time' not in manifest:
                    raise ValueError('Title asset pack must use install-time delivery')
                model = 'conversation_title/assets/models/conversation_title/' + MANIFEST['filename']
                if model not in archive.namelist():
                    raise ValueError('Model missing from install-time asset pack')
            audit([(n, lambda n=n: archive.open(n)) for n in archive.namelist()])
    else:
        with tarfile.open(path) as archive:
            audit([(m.name, lambda m=m: archive.extractfile(m)) for m in archive.getmembers() if m.isfile()])


if __name__ == '__main__':
    main()
