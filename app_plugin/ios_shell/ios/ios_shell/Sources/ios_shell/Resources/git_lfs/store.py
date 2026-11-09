"""Repository discovery, the local LFS object store and atomic file writes."""

import hashlib
import os
import re
import shutil
import tempfile
from typing import BinaryIO, Iterator, List, Optional, Tuple

from .pointer import Pointer, iter_chunks

_OID_RE = re.compile(r'^[0-9a-f]{64}$')


class LfsError(Exception):
    pass


def find_repo(start: str) -> Optional[Tuple[str, str]]:
    """Return (worktree, gitdir) for the nearest enclosing repository."""
    current = os.path.abspath(start)
    while True:
        dotgit = os.path.join(current, '.git')
        if os.path.isdir(dotgit):
            return current, dotgit
        if os.path.isfile(dotgit):
            gitdir = _read_gitdir_file(dotgit)
            if gitdir:
                return current, gitdir
        parent = os.path.dirname(current)
        if parent == current:
            return None
        current = parent


def _read_gitdir_file(path: str) -> Optional[str]:
    with open(path, 'r', encoding='utf-8', errors='replace') as handle:
        line = handle.readline().strip()
    if not line.startswith('gitdir:'):
        return None
    target = line[len('gitdir:'):].strip()
    return os.path.normpath(os.path.join(os.path.dirname(path), target))


def object_path(gitdir: str, oid: str) -> str:
    return os.path.join(gitdir, 'lfs', 'objects', oid[0:2], oid[2:4], oid)


def has_object(gitdir: str, oid: str, size: int) -> bool:
    path = object_path(gitdir, oid)
    return os.path.isfile(path) and os.path.getsize(path) == size


def list_objects(gitdir: str) -> List[Pointer]:
    root = os.path.join(gitdir, 'lfs', 'objects')
    found: List[Pointer] = []
    for dirpath, _dirs, files in os.walk(root):
        for name in files:
            if _OID_RE.match(name):
                found.append((name, os.path.getsize(os.path.join(dirpath, name))))
    return sorted(found)


def store_stream(gitdir: str, oid: str, size: int, chunks: Iterator[bytes]) -> None:
    """Write chunks to a temp file, verify oid/size, then move into the store."""
    tmp_dir = os.path.join(gitdir, 'lfs', 'tmp')
    os.makedirs(tmp_dir, exist_ok=True)
    fd, tmp_path = tempfile.mkstemp(prefix=oid[:16] + '-', dir=tmp_dir)
    digest = hashlib.sha256()
    written = 0
    try:
        with os.fdopen(fd, 'wb') as out:
            for chunk in chunks:
                digest.update(chunk)
                written += len(chunk)
                out.write(chunk)
        if written != size or digest.hexdigest() != oid:
            raise LfsError(f'object {oid[:10]} failed verification '
                           f'(got {written} bytes, sha256 {digest.hexdigest()[:10]})')
        final = object_path(gitdir, oid)
        os.makedirs(os.path.dirname(final), exist_ok=True)
        os.replace(tmp_path, final)
    except BaseException:
        _remove_quietly(tmp_path)
        raise


def store_file(gitdir: str, oid: str, size: int, src: str) -> None:
    with open(src, 'rb') as handle:
        store_stream(gitdir, oid, size, iter_chunks(handle))


def replace_with_object(gitdir: str, oid: str, target: str) -> None:
    """Atomically replace a working-tree file with the stored object's bytes."""
    fd, tmp_path = tempfile.mkstemp(prefix='.lfs-', dir=os.path.dirname(target))
    try:
        with os.fdopen(fd, 'wb') as out, open(object_path(gitdir, oid), 'rb') as src:
            shutil.copyfileobj(src, out, 1024 * 1024)
        if os.path.exists(target):
            shutil.copymode(target, tmp_path)
        os.replace(tmp_path, target)
    except BaseException:
        _remove_quietly(tmp_path)
        raise


def open_object(gitdir: str, oid: str) -> BinaryIO:
    return open(object_path(gitdir, oid), 'rb')


def _remove_quietly(path: str) -> None:
    try:
        os.remove(path)
    except OSError:
        pass
