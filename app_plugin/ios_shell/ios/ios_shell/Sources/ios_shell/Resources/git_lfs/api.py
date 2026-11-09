"""Git LFS batch API client (basic transfer adapter) over urllib."""

import json
import os
import ssl
import urllib.error
import urllib.parse
import urllib.request
from typing import Any, BinaryIO, Dict, Iterator, List, NamedTuple, Optional, Union

from .config import Credentials
from .pointer import Pointer, iter_chunks
from .store import LfsError

LFS_MEDIA_TYPE = 'application/vnd.git-lfs+json'
BATCH_LIMIT = 100
TIMEOUT = 60

Json = Dict[str, Any]
Body = Union[bytes, BinaryIO, None]


class Remote(NamedTuple):
    endpoint: str
    credentials: Optional[Credentials]


def _ssl_context() -> ssl.SSLContext:
    cafile = os.environ.get('SSL_CERT_FILE')
    return ssl.create_default_context(cafile=cafile if cafile and os.path.isfile(cafile) else None)


def _error_message(error: urllib.error.HTTPError, url: str) -> str:
    detail = ''
    try:
        detail = json.loads(error.read() or b'{}').get('message', '')
    except (ValueError, AttributeError, OSError):
        pass
    host = urllib.parse.urlsplit(url).netloc
    message = f'HTTP {error.code} from {host}' + (f': {detail}' if detail else '')
    if error.code in (401, 403):
        message += ('\nhint: authentication failed; set a token with '
                    '`export GIT_LFS_TOKEN=<token>` or `git config user.password <token>`')
    return message


def open_url(method: str, url: str, headers: Dict[str, str], body: Body = None,
             credentials: Optional[Credentials] = None) -> Any:
    request = urllib.request.Request(url, data=body, method=method, headers=headers)
    has_auth = any(name.lower() == 'authorization' for name in headers)
    if credentials and not has_auth:
        request.add_unredirected_header('Authorization', credentials.basic_header())
    try:
        return urllib.request.urlopen(request, timeout=TIMEOUT, context=_ssl_context())
    except urllib.error.HTTPError as error:
        raise LfsError(_error_message(error, url)) from None
    except (urllib.error.URLError, OSError) as error:
        reason = getattr(error, 'reason', error)
        raise LfsError(f'cannot reach {urllib.parse.urlsplit(url).netloc}: {reason}') from None


def batch(remote: Remote, operation: str, objects: List[Pointer]) -> List[Json]:
    body = json.dumps({
        'operation': operation,
        'transfers': ['basic'],
        'objects': [{'oid': oid, 'size': size} for oid, size in objects],
        'hash_algo': 'sha256',
    }).encode()
    headers = {'Accept': LFS_MEDIA_TYPE, 'Content-Type': LFS_MEDIA_TYPE}
    with open_url('POST', remote.endpoint + '/objects/batch', headers, body,
                  remote.credentials) as response:
        try:
            return list(json.loads(response.read()).get('objects') or [])
        except ValueError:
            raise LfsError('invalid JSON in batch response') from None


def chunked(items: List[Pointer], size: int = BATCH_LIMIT) -> Iterator[List[Pointer]]:
    for start in range(0, len(items), size):
        yield items[start:start + size]


def object_error(obj: Json) -> Optional[str]:
    error = obj.get('error')
    if not error:
        return None
    return f'{obj.get("oid", "")[:10]}: {error.get("message", "error")} ({error.get("code", "?")})'


def _action_credentials(remote: Remote, href: str) -> Optional[Credentials]:
    same_host = urllib.parse.urlsplit(href).netloc == urllib.parse.urlsplit(remote.endpoint).netloc
    return remote.credentials if same_host else None


def download(remote: Remote, action: Json) -> Iterator[bytes]:
    href = action['href']
    headers = dict(action.get('header') or {})
    with open_url('GET', href, headers, None, _action_credentials(remote, href)) as response:
        yield from iter_chunks(response)


def upload(remote: Remote, actions: Json, oid: str, size: int, source: BinaryIO) -> None:
    action = actions['upload']
    href = action['href']
    headers = {'Content-Type': 'application/octet-stream', 'Content-Length': str(size),
               **(action.get('header') or {})}
    with open_url('PUT', href, headers, source, _action_credentials(remote, href)) as response:
        response.read()
    verify = actions.get('verify')
    if verify:
        body = json.dumps({'oid': oid, 'size': size}).encode()
        headers = {'Accept': LFS_MEDIA_TYPE, 'Content-Type': LFS_MEDIA_TYPE,
                   **(verify.get('header') or {})}
        with open_url('POST', verify['href'], headers, body,
                      _action_credentials(remote, verify['href'])) as response:
            response.read()
