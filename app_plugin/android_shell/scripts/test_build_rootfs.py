"""Focused checks for reproducibility and locked offline input integrity."""

import io
import json
from pathlib import Path
import tarfile
import tempfile
import unittest
from unittest import mock

import build_rootfs


class RootfsBuilderTest(unittest.TestCase):
    def test_archive_normalizes_metadata_and_materializes_hardlinks(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / 'input.tar'
            with tarfile.open(source, 'w') as archive:
                info = tarfile.TarInfo('usr/bin/tool')
                info.size = 4
                info.mode = 0o755
                info.uid = 1000
                info.gid = 1000
                info.mtime = 123456
                archive.addfile(info, io.BytesIO(b'tool'))
                link = tarfile.TarInfo('usr/bin/alias')
                link.type = tarfile.LNKTYPE
                link.linkname = 'usr/bin/tool'
                archive.addfile(link)
                chain = tarfile.TarInfo('usr/bin/chain')
                chain.type = tarfile.LNKTYPE
                chain.linkname = 'usr/bin/alias'
                archive.addfile(chain)
            first, second = root / 'first.tgz', root / 'second.tgz'
            build_rootfs.normalized_archive(source, first)
            build_rootfs.normalized_archive(source, second)
            self.assertEqual(first.read_bytes(), second.read_bytes())
            self.assertEqual(first.read_bytes()[4:8], b'\0' * 4)
            with tarfile.open(first) as archive:
                for name in ('usr/bin/tool', 'usr/bin/alias', 'usr/bin/chain'):
                    self.assertTrue(archive.getmember(name).isfile())
                    self.assertEqual(archive.extractfile(name).read(), b'tool')
                    self.assertEqual(archive.getmember(name).mtime, 0)
                    self.assertEqual(archive.getmember(name).mode, 0o755)
                    self.assertEqual(archive.getmember(name).uid, 1000)
                self.assertEqual(archive.getmember('usr/bin/tool').uid, 1000)
                self.assertEqual(archive.getmember('usr/bin/tool').mode, 0o755)

    def test_archive_rejects_parent_traversal(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            with tarfile.open(root / 'input.tar', 'w') as archive:
                archive.addfile(tarfile.TarInfo('../escape'))
            with self.assertRaisesRegex(ValueError, 'Unsafe archive member'):
                build_rootfs.normalized_archive(root / 'input.tar', root / 'output.tgz')

    def test_corrupt_cached_input_stops_before_build(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / 'base.tgz').write_bytes(b'base')
            (root / 'package.apk').write_bytes(b'tampered')
            lock = {'base': {'sha256': build_rootfs.sha256(b'base')},
                    'inputs': [{'file': 'package.apk', 'size': 4,
                                'sha256': build_rootfs.sha256(b'good')}]}
            with self.assertRaisesRegex(ValueError, 'Cached input checksum mismatch'):
                build_rootfs.verify_inputs(root, lock)

    def test_config_hash_uses_exact_asset_bytes(self):
        config = build_rootfs.load_config()
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            path = root / 'rootfs-config.json'
            path.write_text(json.dumps(config))
            lock = {'schemaVersion': 1, 'configSha256': build_rootfs.sha256(path.read_bytes()),
                    'recipeSha256': 'recipe', 'sources': {}}
            (root / 'lock.json').write_text(json.dumps(lock))
            path.write_text(json.dumps(config, indent=2))
            with mock.patch.object(build_rootfs, 'CONFIG', path), \
                    mock.patch.object(build_rootfs, 'LOCK', root / 'lock.json'):
                with self.assertRaisesRegex(ValueError, 'Rootfs config changed'):
                    build_rootfs.verify_assets()

    def test_invalid_account_config_fails_before_docker(self):
        original = build_rootfs.load_config()
        for key, value in (('name', 'root'), ('home', '/'),
                           ('home', '/home/gao/.'), ('shell', '/')):
            with self.subTest(key=key, value=value), tempfile.TemporaryDirectory() as temporary:
                config = json.loads(json.dumps(original))
                config['user'][key] = value
                path = Path(temporary) / 'config.json'
                path.write_text(json.dumps(config))
                with mock.patch.object(build_rootfs, 'CONFIG', path):
                    with self.assertRaises(ValueError):
                        build_rootfs.load_config()

    def test_smoke_checks_follow_requested_packages_and_user(self):
        config = {'packages': ['bash'], 'sourcePackages': []}
        script = build_rootfs.command_checks(config)
        self.assertIn('bash --version', script)
        self.assertNotIn('nvim', script)
        self.assertNotIn('1000', script)
        self.assertIn('$WT_UID:$WT_GID:$WT_HOME:$WT_SHELL', script)


if __name__ == '__main__':
    unittest.main()
