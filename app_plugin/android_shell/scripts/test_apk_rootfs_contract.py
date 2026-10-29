"""Check that APK packaging cannot silently change the reviewed shell assets."""

import contextlib
import hashlib
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock
from zipfile import ZipFile

import verify_apk_artifacts


class PackagedRootfsTest(unittest.TestCase):
    def setUp(self):
        self.config = {'schemaVersion': 1, 'user': {'name': 'gao'}}
        self.rootfs = b'\x1f\x8bfixture image bytes'
        self.lock = {
            'configSha256': hashlib.sha256(json.dumps(self.config).encode()).hexdigest(),
            'architectures': {
                abi: {'sha256': hashlib.sha256(self.rootfs).hexdigest()}
                for abi in verify_apk_artifacts.ARCH_CONFIG
            },
        }

    def verify(self, *, config=None, rootfs=None, omitted=None):
        with tempfile.TemporaryDirectory() as temporary:
            apk = Path(temporary) / 'fixture.apk'
            with ZipFile(apk, 'w') as archive:
                if omitted != 'config':
                    archive.writestr('assets/shell/rootfs-config.json', json.dumps(
                        self.config if config is None else config))
                for abi in verify_apk_artifacts.ARCH_CONFIG:
                    if abi != omitted:
                        archive.writestr(f'assets/shell/{abi}/rootfs.tgz',
                                         self.rootfs if rootfs is None else rootfs)
            with mock.patch.object(verify_apk_artifacts, 'verify_assets', return_value=self.lock), \
                    mock.patch.object(verify_apk_artifacts, 'FLUTTER_ABIS', {}), \
                    contextlib.redirect_stdout(io.StringIO()):
                verify_apk_artifacts.verify_apk(apk)

    def test_reviewed_image_and_config_are_accepted(self):
        self.verify()

    def test_packaged_config_change_is_rejected(self):
        with self.assertRaisesRegex(ValueError, 'configuration does not match'):
            self.verify(config={'schemaVersion': 1, 'user': {'name': 'root'}})

    def test_packaged_image_change_is_rejected(self):
        with self.assertRaisesRegex(ValueError, 'locked customized image'):
            self.verify(rootfs=b'\x1f\x8bchanged image')

    def test_missing_runtime_config_is_rejected(self):
        with self.assertRaisesRegex(ValueError, 'Missing runtime rootfs configuration'):
            self.verify(omitted='config')

    def test_missing_architecture_is_rejected(self):
        with self.assertRaisesRegex(ValueError, 'Missing runtime rootfs asset'):
            self.verify(omitted='arm64-v8a')


if __name__ == '__main__':
    unittest.main()
