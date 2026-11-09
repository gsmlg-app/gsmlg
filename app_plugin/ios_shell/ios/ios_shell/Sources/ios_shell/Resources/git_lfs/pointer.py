"""Git LFS pointer files (spec v1) and streaming sha256 hashing."""

import hashlib
import re
from typing import BinaryIO, Iterator, Optional, Tuple

VERSION_URL = 'https://git-lfs.github.com/spec/v1'
MAX_POINTER_SIZE = 1024
CHUNK_SIZE = 1024 * 1024

_OID_RE = re.compile(r'^sha256:([0-9a-f]{64})$')

Pointer = Tuple[str, int]


def format_pointer(oid: str, size: int) -> bytes:
    return f'version {VERSION_URL}\noid sha256:{oid}\nsize {size}\n'.encode()


def parse_pointer(data: bytes) -> Optional[Pointer]:
    if len(data) >= MAX_POINTER_SIZE:
        return None
    try:
        text = data.decode('utf-8')
    except UnicodeDecodeError:
        return None
    lines = [line for line in text.split('\n') if line]
    if not lines or lines[0] != f'version {VERSION_URL}':
        return None
    fields = dict(line.split(' ', 1) for line in lines[1:] if ' ' in line)
    match = _OID_RE.match(fields.get('oid', ''))
    size = fields.get('size', '')
    if not match or not size.isdigit():
        return None
    return match.group(1), int(size)


def read_pointer_file(path: str) -> Optional[Pointer]:
    try:
        with open(path, 'rb') as handle:
            return parse_pointer(handle.read(MAX_POINTER_SIZE))
    except OSError:
        return None


def iter_chunks(handle: BinaryIO) -> Iterator[bytes]:
    while True:
        chunk = handle.read(CHUNK_SIZE)
        if not chunk:
            return
        yield chunk


def hash_file(path: str) -> Pointer:
    digest = hashlib.sha256()
    size = 0
    with open(path, 'rb') as handle:
        for chunk in iter_chunks(handle):
            digest.update(chunk)
            size += len(chunk)
    return digest.hexdigest(), size
