"""git-lfs subcommands. Each command takes (cwd, args) and returns an exit status."""

import os
import sys
from typing import Callable, Dict, Iterator, List, NamedTuple, Optional, Tuple

from . import api
from . import config as cfg
from . import store
from .pointer import Pointer, hash_file, read_pointer_file
from .store import LfsError

VERSION = '0.1.0'


class Repo(NamedTuple):
    worktree: str
    gitdir: str
    config: cfg.Config


def out(message: str) -> None:
    print(message, flush=True)


def err(message: str) -> None:
    print(f'git-lfs: {message}', file=sys.stderr, flush=True)


def open_repo(cwd: str) -> Repo:
    found = store.find_repo(cwd)
    if not found:
        raise LfsError('not in a git repository')
    worktree, gitdir = found
    return Repo(worktree, gitdir, cfg.load_config(gitdir, os.environ))


def connect(repo: Repo, remote: str) -> api.Remote:
    try:
        endpoint, userinfo = cfg.resolve_endpoint(repo.config, repo.worktree, remote)
    except ValueError as error:
        raise LfsError(str(error)) from None
    return api.Remote(endpoint, cfg.resolve_credentials(userinfo, os.environ, repo.config))


def remote_from_args(args: List[str]) -> str:
    positional = [arg for arg in args if not arg.startswith('-')]
    return positional[0] if positional else 'origin'


def tracked_files(repo: Repo) -> Iterator[Tuple[str, str]]:
    """Yield (relative posix path, absolute path) of LFS-tracked working-tree files."""
    patterns = cfg.lfs_patterns(repo.worktree)
    if not patterns:
        return
    for dirpath, dirs, files in os.walk(repo.worktree):
        dirs[:] = sorted(name for name in dirs if name != '.git')
        for name in sorted(files):
            full = os.path.join(dirpath, name)
            rel = os.path.relpath(full, repo.worktree).replace(os.sep, '/')
            if os.path.isfile(full) and not os.path.islink(full) and cfg.is_tracked(patterns, rel):
                yield rel, full


def pointer_files(repo: Repo) -> List[Tuple[str, str, Pointer]]:
    found = ((rel, full, read_pointer_file(full)) for rel, full in tracked_files(repo))
    return [(rel, full, ptr) for rel, full, ptr in found if ptr]


# --- transfers --------------------------------------------------------------

def fetch_objects(repo: Repo, remote: str) -> Tuple[int, List[str]]:
    wanted = {ptr for _rel, _full, ptr in pointer_files(repo)
              if not store.has_object(repo.gitdir, *ptr)}
    if not wanted:
        return 0, []
    conn = connect(repo, remote)
    fetched, errors = 0, []
    for group in api.chunked(sorted(wanted)):
        for obj in api.batch(conn, 'download', group):
            problem = api.object_error(obj) or _download_one(repo, conn, obj)
            if problem:
                errors.append(problem)
            else:
                fetched += 1
    return fetched, errors


def _download_one(repo: Repo, conn: api.Remote, obj: api.Json) -> Optional[str]:
    oid, size = obj.get('oid', ''), int(obj.get('size', 0))
    action = (obj.get('actions') or {}).get('download')
    if not action:
        return f'{oid[:10]}: server returned no download action'
    try:
        store.store_stream(repo.gitdir, oid, size, api.download(conn, action))
    except LfsError as error:
        return f'{oid[:10]}: {error}'
    return None


def checkout_pointers(repo: Repo) -> int:
    count = 0
    for _rel, full, (oid, size) in pointer_files(repo):
        if store.has_object(repo.gitdir, oid, size):
            store.replace_with_object(repo.gitdir, oid, full)
            count += 1
    return count


def push_objects(repo: Repo, remote: str) -> Tuple[int, int, List[str]]:
    objects = store.list_objects(repo.gitdir)
    conn = connect(repo, remote)
    uploaded, skipped, errors = 0, 0, []
    for group in api.chunked(objects):
        for obj in api.batch(conn, 'upload', group):
            oid, size = obj.get('oid', ''), int(obj.get('size', 0))
            actions = obj.get('actions') or {}
            problem = api.object_error(obj)
            if problem:
                errors.append(problem)
            elif 'upload' not in actions:
                skipped += 1
            else:
                try:
                    with store.open_object(repo.gitdir, oid) as source:
                        api.upload(conn, actions, oid, size, source)
                    uploaded += 1
                except (LfsError, OSError) as error:
                    errors.append(f'{oid[:10]}: {error}')
    return uploaded, skipped, errors


def report_errors(errors: List[str]) -> int:
    for problem in errors:
        err(problem)
    return 1 if errors else 0


# --- user commands ----------------------------------------------------------

def cmd_track(cwd: str, args: List[str]) -> int:
    repo = open_repo(cwd)
    path = cfg.attributes_path(repo.worktree)
    existing = cfg.lfs_patterns(repo.worktree)
    if not args:
        out('Listing tracked patterns')
        for pattern in existing:
            out(f'    {pattern} (.gitattributes)')
        return 0
    lines = cfg.read_lines(path)
    for pattern in args:
        if pattern in existing:
            out(f'"{pattern}" already supported')
            continue
        lines.append(f'{pattern} {cfg.LFS_ATTRS}')
        existing.append(pattern)
        out(f'Tracking "{pattern}"')
    _write_lines(path, lines)
    return 0


def cmd_untrack(cwd: str, args: List[str]) -> int:
    if not args:
        err('usage: git lfs untrack <pattern>...')
        return 2
    repo = open_repo(cwd)
    path = cfg.attributes_path(repo.worktree)
    lines = cfg.read_lines(path)
    _write_lines(path, [line for line in lines if cfg.lfs_pattern_of(line) not in args])
    for pattern in args:
        out(f'Untracking "{pattern}"')
    return 0


def _write_lines(path: str, lines: List[str]) -> None:
    with open(path, 'w', encoding='utf-8') as handle:
        handle.write(''.join(line + '\n' for line in lines))


def cmd_ls_files(cwd: str, _args: List[str]) -> int:
    repo = open_repo(cwd)
    for rel, full in tracked_files(repo):
        ptr = read_pointer_file(full)
        oid, marker = (ptr[0], '-') if ptr else (hash_file(full)[0], '*')
        out(f'{oid[:10]} {marker} {rel}')
    return 0


def cmd_fetch(cwd: str, args: List[str]) -> int:
    repo = open_repo(cwd)
    fetched, errors = fetch_objects(repo, remote_from_args(args))
    out(f'Fetched {fetched} object(s).')
    return report_errors(errors)


def cmd_pull(cwd: str, args: List[str]) -> int:
    repo = open_repo(cwd)
    fetched, errors = fetch_objects(repo, remote_from_args(args))
    checked_out = checkout_pointers(repo)
    out(f'Downloaded {fetched} object(s), checked out {checked_out} file(s).')
    return report_errors(errors)


def cmd_push(cwd: str, args: List[str]) -> int:
    repo = open_repo(cwd)
    uploaded, skipped, errors = push_objects(repo, remote_from_args(args))
    out(f'Uploaded {uploaded} object(s), {skipped} already on server.')
    return report_errors(errors)


def cmd_install(_cwd: str, _args: List[str]) -> int:
    out('Git LFS initialized.')
    return 0


def cmd_version(_cwd: str, _args: List[str]) -> int:
    out(f'git-lfs/{VERSION} (web-terminal; python)')
    return 0


def cmd_env(cwd: str, args: List[str]) -> int:
    out(f'git-lfs/{VERSION} (web-terminal; python)')
    repo = open_repo(cwd)
    remote = remote_from_args(args)
    out(f'LocalWorkingDir={repo.worktree}')
    out(f'LocalGitDir={repo.gitdir}')
    out(f'LocalMediaDir={os.path.join(repo.gitdir, "lfs", "objects")}')
    try:
        conn = connect(repo, remote)
    except LfsError as error:
        out(f'Endpoint=<none> ({error})')
        return 0
    creds = conn.credentials
    out(f'Endpoint={conn.endpoint} (remote={remote})')
    out(f'Credentials={"found via " + creds.source if creds else "none"}')
    return 0


# --- hooks for the native git router ----------------------------------------

def cmd_pre_push(cwd: str, args: List[str]) -> int:
    found = store.find_repo(cwd)
    if not found or not store.list_objects(found[1]):
        return 0
    return cmd_push(cwd, [remote_from_args(args)])


def cmd_post_checkout(cwd: str, _args: List[str]) -> int:
    found = store.find_repo(cwd)
    skip = os.environ.get('GIT_LFS_SKIP_SMUDGE', '').lower() in ('1', 'true', 'yes')
    if not found or skip or not cfg.lfs_patterns(found[0]):
        return 0
    try:
        repo = open_repo(cwd)
        _fetched, errors = fetch_objects(repo, 'origin')
        checkout_pointers(repo)
    except (LfsError, OSError, ValueError) as error:
        errors = [str(error)]
    for problem in errors:
        print(f'git-lfs: warning: {problem}', file=sys.stderr, flush=True)
    return 0


def clone_target(args: List[str]) -> Optional[str]:
    positional = [arg for arg in args if not arg.startswith('-')]
    if positional and positional[0] == 'clone':
        positional = positional[1:]
    if len(positional) >= 2:
        return positional[1]
    if not positional:
        return None
    url = positional[0].rstrip('/')
    if url.endswith('.git'):
        url = url[:-4].rstrip('/')
    return url.replace(':', '/').rsplit('/', 1)[-1] or None


def cmd_post_clone(cwd: str, args: List[str]) -> int:
    target = clone_target(args)
    if not target:
        return 0
    directory = os.path.join(cwd, target)
    if not os.path.isdir(directory):
        print(f'git-lfs: warning: clone directory not found: {target}', file=sys.stderr)
        return 0
    return cmd_post_checkout(directory, [])


COMMANDS: Dict[str, Callable[[str, List[str]], int]] = {
    'track': cmd_track,
    'untrack': cmd_untrack,
    'ls-files': cmd_ls_files,
    'fetch': cmd_fetch,
    'pull': cmd_pull,
    'push': cmd_push,
    'install': cmd_install,
    'version': cmd_version,
    'env': cmd_env,
    'pre-push': cmd_pre_push,
    'post-checkout': cmd_post_checkout,
    'post-clone': cmd_post_clone,
}
