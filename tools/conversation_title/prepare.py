#!/usr/bin/env python3
"""Prepare or verify the pinned title model; never used at application runtime."""
import argparse
import hashlib
import json
from pathlib import Path
import sys
import urllib.request

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = json.loads(Path(__file__).with_name('model.json').read_text())
DESTINATION = ROOT / 'assets/models/conversation_title' / MANIFEST['filename']


def verify(path):
    if not path.is_file() or path.stat().st_size != MANIFEST['size']:
        raise ValueError(f'Missing or wrong-size title model: {path}')
    digest = hashlib.sha256()
    with path.open('rb') as source:
        while block := source.read(1024 * 1024):
            digest.update(block)
    digest = digest.hexdigest()
    if digest != MANIFEST['sha256']:
        raise ValueError(f'Title model checksum mismatch: {path}')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--download', action='store_true')
    parser.add_argument('--file', type=Path, default=DESTINATION)
    args = parser.parse_args()
    if args.download:
        try:
            verify(args.file)
        except ValueError:
            args.file.parent.mkdir(parents=True, exist_ok=True)
            temporary = args.file.with_suffix('.partial')
            url = (f'https://huggingface.co/{MANIFEST["repository"]}/resolve/'
                   f'{MANIFEST["revision"]}/{MANIFEST["filename"]}')
            try:
                with urllib.request.urlopen(url, timeout=120) as source, temporary.open('wb') as out:
                    while block := source.read(1024 * 1024):
                        out.write(block)
                verify(temporary)
                temporary.replace(args.file)
            finally:
                temporary.unlink(missing_ok=True)
    verify(args.file)
    print(f'Verified {args.file}: {MANIFEST["sha256"]} ({MANIFEST["size"]} bytes)')


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError) as error:
        sys.exit(f'{error}\nRun python3 tools/conversation_title/prepare.py --download before building.')
