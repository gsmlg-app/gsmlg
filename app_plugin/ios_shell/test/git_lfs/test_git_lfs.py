"""Host-side tests for the embedded git-lfs implementation (stdlib only)."""

import base64
import contextlib
import hashlib
import http.server
import io
import json
import os
import sys
import tempfile
import threading
import unittest
from typing import Dict, List

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.normpath(os.path.join(HERE, '..', '..', 'ios', 'Resources')))

from git_lfs import commands  # noqa: E402
from git_lfs import config as cfg  # noqa: E402
from git_lfs import main  # noqa: E402
from git_lfs import store  # noqa: E402
from git_lfs.pointer import format_pointer, hash_file, parse_pointer  # noqa: E402

TOKEN_VARS = ('GIT_LFS_TOKEN', 'GITHUB_TOKEN', 'GH_TOKEN', 'GIT_LFS_SKIP_SMUDGE', 'HOME')


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def write(path: str, data: bytes) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'wb') as handle:
        handle.write(data)


def read(path: str) -> bytes:
    with open(path, 'rb') as handle:
        return handle.read()


class EnvMixin(unittest.TestCase):
    def setUp(self) -> None:
        self._saved = {name: os.environ.get(name) for name in TOKEN_VARS}
        for name in TOKEN_VARS:
            os.environ.pop(name, None)
        self._tmp = tempfile.TemporaryDirectory()
        self.tmp = os.path.realpath(self._tmp.name)
        os.environ['HOME'] = os.path.join(self.tmp, 'home')

    def tearDown(self) -> None:
        for name, value in self._saved.items():
            if value is None:
                os.environ.pop(name, None)
            else:
                os.environ[name] = value
        self._tmp.cleanup()

    def make_repo(self, git_config: str = '', attributes: str = '') -> str:
        root = os.path.join(self.tmp, 'repo')
        os.makedirs(os.path.join(root, '.git'))
        write(os.path.join(root, '.git', 'config'), git_config.encode())
        if attributes:
            write(os.path.join(root, '.gitattributes'), attributes.encode())
        return root

    def run_cli(self, cwd: str, *argv: str) -> tuple:
        stdout, stderr = io.StringIO(), io.StringIO()
        previous = os.getcwd()
        os.chdir(cwd)
        try:
            with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
                status = main.main(list(argv))
        finally:
            os.chdir(previous)
        return status, stdout.getvalue(), stderr.getvalue()


class NamespaceTest(EnvMixin):
    def test_no_bare_module_names_registered(self) -> None:
        repo = self.make_repo(attributes='*.bin filter=lfs diff=lfs merge=lfs -text\n')
        self.assertEqual(self.run_cli(repo, 'ls-files')[0], 0)
        self.assertEqual(self.run_cli(repo, 'version')[0], 0)
        leaked = {'commands', 'config', 'api', 'store', 'pointer', 'main'} & set(sys.modules)
        self.assertEqual(leaked, set())
        self.assertIn('git_lfs.commands', sys.modules)


class PointerTest(unittest.TestCase):
    def test_round_trip(self) -> None:
        oid = sha(b'hello')
        data = format_pointer(oid, 5)
        self.assertEqual(data, ('version https://git-lfs.github.com/spec/v1\n'
                                f'oid sha256:{oid}\nsize 5\n').encode())
        self.assertEqual(parse_pointer(data), (oid, 5))

    def test_rejects_non_pointers(self) -> None:
        self.assertIsNone(parse_pointer(b'hello world'))
        self.assertIsNone(parse_pointer(b'version https://git-lfs.github.com/spec/v1\n'
                                        b'oid sha256:XYZ\nsize 1\n'))
        self.assertIsNone(parse_pointer(format_pointer(sha(b''), 0) + b' ' * 1100))
        self.assertIsNone(parse_pointer(b'\xff\xfe'))


class PatternTest(unittest.TestCase):
    def test_basename_patterns(self) -> None:
        self.assertTrue(cfg.matches('*.bin', 'a.bin'))
        self.assertTrue(cfg.matches('*.bin', 'deep/dir/a.bin'))
        self.assertFalse(cfg.matches('*.bin', 'a.bin.txt'))
        self.assertTrue(cfg.matches('file?.dat', 'x/file1.dat'))
        self.assertTrue(cfg.matches('*.[pP][nN][gG]', 'img/A.PNG'))

    def test_anchored_patterns(self) -> None:
        self.assertTrue(cfg.matches('assets/*.psd', 'assets/a.psd'))
        self.assertFalse(cfg.matches('assets/*.psd', 'x/assets/a.psd'))
        self.assertFalse(cfg.matches('assets/*.psd', 'assets/sub/a.psd'))
        self.assertTrue(cfg.matches('/top.bin', 'top.bin'))
        self.assertFalse(cfg.matches('/top.bin', 'sub/top.bin'))

    def test_double_star(self) -> None:
        self.assertTrue(cfg.matches('media/**', 'media/a/b/c.mp4'))
        self.assertTrue(cfg.matches('**/*.zip', 'a.zip'))
        self.assertTrue(cfg.matches('**/*.zip', 'x/y/a.zip'))
        self.assertTrue(cfg.matches('a/**/b.bin', 'a/b.bin'))
        self.assertTrue(cfg.matches('a/**/b.bin', 'a/x/y/b.bin'))
        self.assertFalse(cfg.matches('a/**/b.bin', 'z/a/b.bin'))


class TrackTest(EnvMixin):
    def test_track_list_untrack(self) -> None:
        repo = self.make_repo(attributes='*.txt text\n')
        status, output, _ = self.run_cli(repo, 'track', '*.bin', 'assets/**')
        self.assertEqual(status, 0)
        self.assertIn('Tracking "*.bin"', output)
        status, output, _ = self.run_cli(repo, 'track', '*.bin')
        self.assertIn('already supported', output)
        self.assertEqual(read(os.path.join(repo, '.gitattributes')).decode(),
                         '*.txt text\n*.bin filter=lfs diff=lfs merge=lfs -text\n'
                         'assets/** filter=lfs diff=lfs merge=lfs -text\n')
        _, output, _ = self.run_cli(os.path.join(repo, '.git'), 'track')
        self.assertEqual(output, 'Listing tracked patterns\n    *.bin (.gitattributes)\n'
                                 '    assets/** (.gitattributes)\n')
        status, output, _ = self.run_cli(repo, 'untrack', '*.bin')
        self.assertEqual((status, output), (0, 'Untracking "*.bin"\n'))
        self.assertEqual(cfg.lfs_patterns(repo), ['assets/**'])
        self.assertIn('*.txt text', cfg.read_lines(os.path.join(repo, '.gitattributes')))

    def test_outside_repo(self) -> None:
        status, _, error = self.run_cli(self.tmp, 'track')
        self.assertEqual(status, 1)
        self.assertIn('git-lfs: not in a git repository', error)


class ConfigTest(EnvMixin):
    def test_parse_git_config(self) -> None:
        parsed = cfg.parse_git_config(
            '# comment\n[remote "origin"]\n\turl = "https://h/o/r.git" ; trailing\n'
            '[lfs]\n  url = https://lfs.example/x # c\n[user]\nname = A "B"\n[core]\nbare\n')
        self.assertEqual(cfg.get(parsed, 'remote.origin.url'), 'https://h/o/r.git')
        self.assertEqual(cfg.get(parsed, 'lfs.url'), 'https://lfs.example/x')
        self.assertEqual(cfg.get(parsed, 'user.name'), 'A B')
        self.assertEqual(cfg.get(parsed, 'core.bare'), 'true')

    def test_endpoint_conversion(self) -> None:
        cases = {
            'https://github.com/o/r': ('https://github.com/o/r.git/info/lfs', None),
            'https://github.com/o/r.git/': ('https://github.com/o/r.git/info/lfs', None),
            'https://u:p%40w@host:8443/o/r.git': ('https://host:8443/o/r.git/info/lfs', 'u:p@w'),
            'git@github.com:o/r.git': ('https://github.com/o/r.git/info/lfs', None),
            'github.com:o/r': ('https://github.com/o/r.git/info/lfs', None),
            'ssh://git@host:2222/o/r.git': ('https://host/o/r.git/info/lfs', None),
            'ssh://host/o/r': ('https://host/o/r.git/info/lfs', None),
        }
        for url, expected in cases.items():
            with self.subTest(url=url):
                self.assertEqual(cfg.remote_to_endpoint(url), expected)

    def test_resolve_endpoint_sources(self) -> None:
        repo = self.make_repo('[remote "origin"]\n\turl = git@host:o/r.git\n')
        config = cfg.load_config(os.path.join(repo, '.git'), os.environ)
        self.assertEqual(cfg.resolve_endpoint(config, repo, 'origin'),
                         ('https://host/o/r.git/info/lfs', None))
        self.assertEqual(cfg.resolve_endpoint(config, repo, 'https://other/x/y.git')[0],
                         'https://other/x/y.git/info/lfs')
        with self.assertRaises(ValueError):
            cfg.resolve_endpoint(config, repo, 'upstream')
        write(os.path.join(repo, '.lfsconfig'), b'[lfs]\n\turl = https://me:tok@lfs.host/api/\n')
        self.assertEqual(cfg.resolve_endpoint(config, repo, 'origin'),
                         ('https://lfs.host/api', 'me:tok'))

    def test_repo_config_overrides_home(self) -> None:
        write(os.path.join(os.environ['HOME'], '.gitconfig'),
              b'[user]\n\tname = home\n\tpassword = homepw\n')
        repo = self.make_repo('[user]\n\tname = repo\n')
        config = cfg.load_config(os.path.join(repo, '.git'), os.environ)
        self.assertEqual(cfg.get(config, 'user.name'), 'repo')
        self.assertEqual(cfg.get(config, 'user.password'), 'homepw')

    def test_credential_priority(self) -> None:
        config = {'user.name': ['alice'], 'user.password': ['cfgpw']}
        env: Dict[str, str] = {'GIT_LFS_TOKEN': 't1', 'GITHUB_TOKEN': 't2', 'GH_TOKEN': 't3'}
        resolve = cfg.resolve_credentials
        self.assertEqual(resolve('bob:pw', env, config)[:2], ('bob', 'pw'))
        self.assertEqual(resolve(None, env, config)[:2], ('alice', 't1'))
        self.assertEqual(resolve('bob', env, config)[:2], ('bob', 't1'))
        self.assertEqual(resolve(None, {'GH_TOKEN': 't3', 'GITHUB_TOKEN': 't2'}, {})[:2],
                         ('x-access-token', 't2'))
        self.assertEqual(resolve(None, {'GH_TOKEN': 't3'}, {})[:2], ('x-access-token', 't3'))
        self.assertEqual(resolve(None, {}, config)[:2], ('alice', 'cfgpw'))
        self.assertIsNone(resolve(None, {}, {'user.name': ['alice']}))

    def test_env_flags_applied(self) -> None:
        repo = self.make_repo('[remote "origin"]\n\turl = https://h/o/r\n')
        status, output, _ = self.run_cli(repo, '--env=GIT_LFS_TOKEN=secret-value', 'env')
        self.assertEqual(status, 0)
        self.assertEqual(os.environ['GIT_LFS_TOKEN'], 'secret-value')
        self.assertIn('Endpoint=https://h/o/r.git/info/lfs', output)
        self.assertIn('Credentials=found via GIT_LFS_TOKEN', output)
        self.assertNotIn('secret-value', output)


class CloneTargetTest(unittest.TestCase):
    def test_derivation(self) -> None:
        target = commands.clone_target
        self.assertEqual(target(['https://github.com/o/repo.git']), 'repo')
        self.assertEqual(target(['clone', 'https://github.com/o/repo/']), 'repo')
        self.assertEqual(target(['git@github.com:o/repo.git']), 'repo')
        self.assertEqual(target(['host:repo.git']), 'repo')
        self.assertEqual(target(['-q', 'https://h/o/r.git', 'dest']), 'dest')
        self.assertEqual(target(['https://h/o/r.git/']), 'r')
        self.assertIsNone(target([]))


class FakeLfsServer:
    """In-process LFS server implementing batch + basic transfer + verify."""

    def __init__(self) -> None:
        self.objects: Dict[str, bytes] = {}
        self.auth_seen: List[str] = []
        self.verified: List[str] = []
        self.batch_sizes: List[int] = []
        self.require_auth = 'Basic ' + base64.b64encode(b'x-access-token:tok').decode()
        server = self

        class Handler(http.server.BaseHTTPRequestHandler):
            def log_message(self, *_args: object) -> None:
                pass

            def _send(self, code: int, body: bytes = b'', ctype: str = 'application/vnd.git-lfs+json') -> None:
                self.send_response(code)
                self.send_header('Content-Type', ctype)
                self.send_header('Content-Length', str(len(body)))
                self.end_headers()
                self.wfile.write(body)

            def _body(self) -> bytes:
                return self.rfile.read(int(self.headers.get('Content-Length', 0)))

            def do_POST(self) -> None:
                body = self._body()
                if self.path.endswith('/verify'):
                    server.verified.append(json.loads(body)['oid'])
                    return self._send(200)
                server.auth_seen.append(self.headers.get('Authorization', ''))
                if self.headers.get('Authorization') != server.require_auth:
                    return self._send(401, b'{"message": "Bad credentials"}')
                request = json.loads(body)
                server.batch_sizes.append(len(request['objects']))
                return self._send(200, json.dumps({'transfer': 'basic', 'objects': [
                    server.describe(request['operation'], obj) for obj in request['objects']]}).encode())

            def do_GET(self) -> None:
                oid = self.path.rsplit('/', 1)[-1]
                if self.headers.get('Authorization') != 'Bearer action-token':
                    return self._send(403)
                self._send(200, server.objects[oid], 'application/octet-stream')

            def do_PUT(self) -> None:
                oid = self.path.rsplit('/', 1)[-1]
                server.objects[oid] = self._body()
                self._send(200)

        self.httpd = http.server.ThreadingHTTPServer(('127.0.0.1', 0), Handler)
        self.base = f'http://127.0.0.1:{self.httpd.server_address[1]}'
        self.thread = threading.Thread(target=self.httpd.serve_forever, daemon=True)

    def describe(self, operation: str, obj: dict) -> dict:
        oid, size = obj['oid'], obj['size']
        href = f'{self.base}/storage/{oid}'
        header = {'Authorization': 'Bearer action-token'}
        if operation == 'download':
            if oid not in self.objects:
                return {**obj, 'error': {'code': 404, 'message': 'Object does not exist'}}
            return {**obj, 'actions': {'download': {'href': href, 'header': header}}}
        if oid in self.objects:
            return obj
        return {**obj, 'actions': {'upload': {'href': href, 'header': header},
                                   'verify': {'href': href + '/verify', 'header': header}}}

    def __enter__(self) -> 'FakeLfsServer':
        self.thread.start()
        return self

    def __exit__(self, *_exc: object) -> None:
        self.httpd.shutdown()
        self.httpd.server_close()


class EndToEndTest(EnvMixin):
    def setUp(self) -> None:
        super().setUp()
        self.server = FakeLfsServer().__enter__()
        self.addCleanup(self.server.__exit__)
        self.repo = self.make_repo(f'[remote "origin"]\n\turl = {self.server.base}/o/r.git\n',
                                   '*.bin filter=lfs diff=lfs merge=lfs -text\n')
        self.gitdir = os.path.join(self.repo, '.git')
        os.environ['GIT_LFS_TOKEN'] = 'tok'

    def add_pointer(self, rel: str, data: bytes) -> str:
        oid = sha(data)
        write(os.path.join(self.repo, rel), format_pointer(oid, len(data)))
        return oid

    def test_fetch_and_pull(self) -> None:
        big = os.urandom(3 * 1024 * 1024 + 7)
        small = b'small payload'
        self.server.objects = {sha(big): big, sha(small): small}
        self.add_pointer('data/big.bin', big)
        self.add_pointer('small.bin', small)
        write(os.path.join(self.repo, 'notes.txt'), b'plain')

        status, output, _ = self.run_cli(self.repo, 'ls-files')
        self.assertEqual(status, 0)
        self.assertIn(f'{sha(big)[:10]} - data/big.bin', output)
        self.assertNotIn('notes.txt', output)

        status, output, error = self.run_cli(self.repo, 'fetch')
        self.assertEqual((status, error), (0, ''))
        self.assertIn('Fetched 2 object(s).', output)
        self.assertTrue(store.has_object(self.gitdir, sha(big), len(big)))

        status, output, _ = self.run_cli(os.path.join(self.repo, 'data'), 'pull')
        self.assertEqual(status, 0)
        self.assertIn('Downloaded 0 object(s), checked out 2 file(s).', output)
        self.assertEqual(read(os.path.join(self.repo, 'data', 'big.bin')), big)
        self.assertEqual(read(os.path.join(self.repo, 'small.bin')), small)
        self.assertEqual(os.listdir(os.path.join(self.gitdir, 'lfs', 'tmp')), [])

        _, output, _ = self.run_cli(self.repo, 'ls-files')
        self.assertIn(f'{sha(small)[:10]} * small.bin', output)

    def test_missing_object_reports_error(self) -> None:
        self.add_pointer('gone.bin', b'never uploaded')
        status, _, error = self.run_cli(self.repo, 'pull')
        self.assertEqual(status, 1)
        self.assertIn('Object does not exist', error)

    def test_corrupt_download_rejected(self) -> None:
        data = b'expected content'
        oid = self.add_pointer('x.bin', data)
        self.server.objects[oid] = b'tampered content'
        status, _, error = self.run_cli(self.repo, 'fetch')
        self.assertEqual(status, 1)
        self.assertIn('failed verification', error)
        self.assertFalse(os.path.exists(store.object_path(self.gitdir, oid)))

    def test_bad_credentials_hint(self) -> None:
        self.add_pointer('a.bin', b'abc')
        os.environ['GIT_LFS_TOKEN'] = 'wrong-secret'
        status, _, error = self.run_cli(self.repo, 'fetch')
        self.assertEqual(status, 1)
        self.assertIn('HTTP 401', error)
        self.assertIn('GIT_LFS_TOKEN', error)
        self.assertNotIn('wrong-secret', error)

    def test_push_and_pre_push(self) -> None:
        status, output, error = self.run_cli(self.repo, 'pre-push', 'origin', 'main')
        self.assertEqual((status, output, error), (0, '', ''))
        self.assertEqual(self.server.auth_seen, [])

        payloads = [f'object {index}'.encode() for index in range(105)]
        for data in payloads:
            write(os.path.join(self.repo, 'tmpsrc'), data)
            store.store_file(self.gitdir, sha(data), len(data), os.path.join(self.repo, 'tmpsrc'))
        self.server.objects[sha(payloads[0])] = payloads[0]

        status, output, _ = self.run_cli(self.repo, 'push', '--all')
        self.assertEqual(status, 0)
        self.assertIn('Uploaded 104 object(s), 1 already on server.', output)
        self.assertEqual(self.server.batch_sizes, [100, 5])
        self.assertEqual(len(self.server.verified), 104)
        self.assertEqual(self.server.objects[sha(payloads[50])], payloads[50])

        status, output, _ = self.run_cli(self.repo, 'pre-push', '-u', 'origin', 'main')
        self.assertEqual(status, 0)
        self.assertIn('Uploaded 0 object(s), 105 already on server.', output)

        os.environ['GIT_LFS_TOKEN'] = 'bad'
        status, _, _ = self.run_cli(self.repo, 'pre-push', 'origin')
        self.assertEqual(status, 1)

    def test_post_checkout_and_clone(self) -> None:
        data = b'checked out content'
        self.server.objects[sha(data)] = data
        self.add_pointer('a.bin', data)

        os.environ['GIT_LFS_SKIP_SMUDGE'] = '1'
        self.assertEqual(self.run_cli(self.repo, 'post-checkout')[0], 0)
        self.assertIsNotNone(parse_pointer(read(os.path.join(self.repo, 'a.bin'))))
        del os.environ['GIT_LFS_SKIP_SMUDGE']

        status, _, error = self.run_cli(self.tmp, 'post-clone', f'{self.server.base}/o/repo.git')
        self.assertEqual((status, error), (0, ''))
        self.assertEqual(read(os.path.join(self.repo, 'a.bin')), data)

    def test_post_checkout_warns_on_network_failure(self) -> None:
        self.add_pointer('a.bin', b'abc')
        os.environ['GIT_LFS_TOKEN'] = 'wrong'
        status, _, error = self.run_cli(self.repo, 'post-checkout')
        self.assertEqual(status, 0)
        self.assertIn('warning', error)

    def test_hash_file_matches(self) -> None:
        path = os.path.join(self.repo, 'x.bin')
        write(path, b'abc')
        self.assertEqual(hash_file(path), (sha(b'abc'), 3))


if __name__ == '__main__':
    unittest.main()
