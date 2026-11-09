"""Git config / .gitattributes parsing, LFS endpoint and credential resolution."""

import base64
import os
import re
import urllib.parse
from typing import Dict, List, Mapping, NamedTuple, Optional, Tuple

Config = Dict[str, List[str]]

LFS_ATTRS = 'filter=lfs diff=lfs merge=lfs -text'

_SECTION_RE = re.compile(r'^\[\s*([A-Za-z0-9.-]+)(?:\s+"((?:[^"\\]|\\.)*)")?\s*\](.*)$')
_SCP_RE = re.compile(r'^(?:[^@/]+@)?([^:/]+):(?!//)(.+)$')
_ESCAPES = {'n': '\n', 't': '\t', 'b': '\b'}


class Credentials(NamedTuple):
    username: str
    password: str
    source: str

    def basic_header(self) -> str:
        raw = f'{self.username}:{self.password}'.encode()
        return 'Basic ' + base64.b64encode(raw).decode()


# --- git config -----------------------------------------------------------

def _parse_value(raw: str) -> str:
    out: List[str] = []
    quoted = False
    index = 0
    while index < len(raw):
        char = raw[index]
        if char == '"':
            quoted = not quoted
        elif char == '\\' and index + 1 < len(raw):
            index += 1
            out.append(_ESCAPES.get(raw[index], raw[index]))
        elif char in '#;' and not quoted:
            break
        else:
            out.append(char)
        index += 1
    return ''.join(out).strip()


def parse_git_config(text: str) -> Config:
    config: Config = {}
    section = ''
    for raw_line in text.splitlines():
        line = raw_line.strip()
        match = _SECTION_RE.match(line)
        if match:
            name, sub, line = match.group(1), match.group(2), match.group(3).strip()
            section = name.lower() if sub is None else f'{name.lower()}.{sub}'
        if not line or line[0] in '#;' or not section:
            continue
        key, sep, value = line.partition('=')
        full_key = f'{section}.{key.strip().lower()}'
        config.setdefault(full_key, []).append(_parse_value(value) if sep else 'true')
    return config


def read_config_file(path: str) -> Config:
    try:
        with open(path, 'r', encoding='utf-8', errors='replace') as handle:
            return parse_git_config(handle.read())
    except OSError:
        return {}


def load_config(gitdir: str, env: Mapping[str, str]) -> Config:
    home = env.get('HOME', '')
    user = read_config_file(os.path.join(home, '.gitconfig')) if home else {}
    return {**user, **read_config_file(os.path.join(gitdir, 'config'))}


def get(config: Config, key: str) -> Optional[str]:
    values = config.get(key)
    return values[-1] if values else None


# --- .gitattributes ---------------------------------------------------------

def attributes_path(worktree: str) -> str:
    return os.path.join(worktree, '.gitattributes')


def read_lines(path: str) -> List[str]:
    try:
        with open(path, 'r', encoding='utf-8') as handle:
            return handle.read().splitlines()
    except OSError:
        return []


def lfs_pattern_of(line: str) -> Optional[str]:
    parts = line.split()
    if len(parts) < 2 or parts[0].startswith('#'):
        return None
    return parts[0] if 'filter=lfs' in parts[1:] else None


def lfs_patterns(worktree: str) -> List[str]:
    found = (lfs_pattern_of(line) for line in read_lines(attributes_path(worktree)))
    return [pattern for pattern in found if pattern]


def pattern_regex(pattern: str) -> 're.Pattern[str]':
    body = pattern.lstrip('/')
    out: List[str] = []
    index = 0
    while index < len(body):
        if body.startswith('**/', index) and (index == 0 or body[index - 1] == '/'):
            out.append('(?:.*/)?')
            index += 3
        elif body.startswith('**', index):
            out.append('.*')
            index += 2
        elif body[index] == '*':
            out.append('[^/]*')
            index += 1
        elif body[index] == '?':
            out.append('[^/]')
            index += 1
        elif body[index] == '[' and ']' in body[index + 1:]:
            end = body.index(']', index + 1)
            out.append('[' + body[index + 1:end].replace('!', '^', 1) + ']')
            index = end + 1
        else:
            out.append(re.escape(body[index]))
            index += 1
    return re.compile(''.join(out))


def matches(pattern: str, rel_path: str) -> bool:
    anchored = '/' in pattern.rstrip('/')
    subject = rel_path if anchored else rel_path.rsplit('/', 1)[-1]
    return pattern_regex(pattern).fullmatch(subject) is not None


def is_tracked(patterns: List[str], rel_path: str) -> bool:
    return any(matches(pattern, rel_path) for pattern in patterns)


# --- endpoint ---------------------------------------------------------------

def looks_like_url(value: str) -> bool:
    return '://' in value or bool(_SCP_RE.match(value)) and not os.path.exists(value)


def _with_lfs_suffix(scheme: str, netloc: str, path: str) -> str:
    path = '/' + path.strip('/')
    if not path.endswith('.git'):
        path += '.git'
    return f'{scheme}://{netloc}{path}/info/lfs'


def _split_userinfo(netloc: str) -> Tuple[Optional[str], str]:
    userinfo, sep, host = netloc.rpartition('@')
    return (urllib.parse.unquote(userinfo), host) if sep else (None, netloc)


def remote_to_endpoint(url: str) -> Tuple[str, Optional[str]]:
    """Convert a git remote URL to (lfs_endpoint, http_userinfo)."""
    if '://' not in url:
        scp = _SCP_RE.match(url)
        if not scp:
            raise ValueError(f'unsupported remote URL: {url}')
        return _with_lfs_suffix('https', scp.group(1), scp.group(2)), None
    parts = urllib.parse.urlsplit(url)
    userinfo, host = _split_userinfo(parts.netloc)
    if parts.scheme in ('ssh', 'git+ssh', 'ssh+git', 'git'):
        return _with_lfs_suffix('https', host.split(':')[0], parts.path), None
    return _with_lfs_suffix(parts.scheme, host, parts.path), userinfo


def strip_userinfo(url: str) -> Tuple[str, Optional[str]]:
    parts = urllib.parse.urlsplit(url)
    userinfo, host = _split_userinfo(parts.netloc)
    return urllib.parse.urlunsplit(parts._replace(netloc=host)).rstrip('/'), userinfo


def remote_url(config: Config, remote: str) -> Optional[str]:
    if looks_like_url(remote):
        return remote
    return get(config, f'remote.{remote}.url')


def resolve_endpoint(config: Config, worktree: str, remote: str) -> Tuple[str, Optional[str]]:
    lfs_url = (get(config, f'remote.{remote}.lfsurl') or get(config, 'lfs.url')
               or get(read_config_file(os.path.join(worktree, '.lfsconfig')), 'lfs.url'))
    if lfs_url:
        return strip_userinfo(lfs_url)
    url = remote_url(config, remote)
    if not url:
        raise ValueError(f'no URL configured for remote "{remote}" '
                         '(set remote.<name>.url or lfs.url)')
    return remote_to_endpoint(url)


# --- credentials ------------------------------------------------------------

def resolve_credentials(userinfo: Optional[str], env: Mapping[str, str],
                        config: Config) -> Optional[Credentials]:
    url_user, has_password, url_password = (userinfo or '').partition(':')
    if url_user and has_password:
        return Credentials(url_user, url_password, 'remote URL')
    username = url_user or get(config, 'user.name') or 'x-access-token'
    for name in ('GIT_LFS_TOKEN', 'GITHUB_TOKEN', 'GH_TOKEN'):
        if env.get(name):
            return Credentials(username, env[name], name)
    config_user, config_password = get(config, 'user.name'), get(config, 'user.password')
    if config_user and config_password:
        return Credentials(config_user, config_password, 'git config user.password')
    return None
