"""Offline launch-contract checks for the actual bundled Android assets."""

import io
import pathlib
import re
import struct
import subprocess
import tempfile
import unittest
from unittest import mock

import setup_alpine_proot
import build_rootfs

PLUGIN = pathlib.Path(__file__).resolve().parent.parent
ROOT = PLUGIN.parent.parent
MAIN = PLUGIN / 'android/src/main'


def needed_libraries(path):
    data = path.read_bytes()
    is64 = data[4] == 2
    endian = '<' if data[5] == 1 else '>'
    header = struct.unpack_from(endian + ('HHIQQQIHHHHHH' if is64 else 'HHIIIIIHHHHHH'), data, 16)
    loads = []
    dynamic = None
    for index in range(header[9]):
        segment = struct.unpack_from(endian + ('IIQQQQQQ' if is64 else 'IIIIIIII'), data, header[4] + index * header[8])
        offset, address, size = (segment[2], segment[3], segment[5]) if is64 else (segment[1], segment[2], segment[4])
        if segment[0] == 1:
            loads.append((address, offset, size))
        if segment[0] == 2:
            dynamic = (offset, size)
    if dynamic is None:
        return []
    tags = []
    for offset in range(dynamic[0], sum(dynamic), 16 if is64 else 8):
        tag, value = struct.unpack_from(endian + ('qQ' if is64 else 'iI'), data, offset)
        if tag == 0:
            break
        tags.append((tag, value))
    strings_address = next(value for tag, value in tags if tag == 5)
    strings_offset = next(offset + strings_address - address for address, offset, size in loads if address <= strings_address < address + size)
    return [data[strings_offset + value:data.index(0, strings_offset + value)].decode() for tag, value in tags if tag == 1]


class AndroidArtifactsTest(unittest.TestCase):
    def test_runtime_rootfs_asset_avoids_android_gzip_expansion(self):
        source = (MAIN / 'kotlin/app/gsmlg/android_shell/AndroidShellPlugin.kt').read_text()
        asset_names = re.findall(r'"shell/\$arch/([^"]+)"', source)
        self.assertTrue(asset_names)
        # AGP removes .gz and gunzips assets before AAPT sees them.
        self.assertEqual(set(asset_names), {'rootfs.tgz'})
        for abi in setup_alpine_proot.ARCH_CONFIG:
            with self.subTest(abi=abi):
                content = (MAIN / 'assets/shell' / abi / asset_names[0]).read_bytes()
                self.assertTrue(content.startswith(b'\x1f\x8b'))

    def test_download_rejects_content_with_wrong_checksum(self):
        with mock.patch.object(setup_alpine_proot.urllib.request, 'urlopen',
                               return_value=io.BytesIO(b'tampered artifact')):
            with self.assertRaisesRegex(ValueError, 'SHA-256 mismatch'):
                setup_alpine_proot.verified_download('https://invalid.test/artifact', '0' * 64)

    def test_customized_rootfs_archives_match_their_lock(self):
        lock = build_rootfs.verify_assets()
        self.assertEqual(set(lock['architectures']), set(setup_alpine_proot.ARCH_CONFIG))

    def test_native_setup_preserves_customized_rootfs(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = pathlib.Path(temporary)
            assets = directory / 'assets'
            rootfs = assets / 'arm64-v8a/rootfs.tgz'
            rootfs.parent.mkdir(parents=True)
            rootfs.write_bytes(b'customized rootfs must survive native updates')
            with mock.patch.object(setup_alpine_proot, 'ASSETS_DIR', assets), \
                    mock.patch.object(setup_alpine_proot, 'PLUGIN_DIR', directory), \
                    mock.patch.object(setup_alpine_proot, 'JNILIBS_DIR', directory / 'jniLibs'), \
                    mock.patch.object(setup_alpine_proot, 'verified_download', return_value=b'component'), \
                    mock.patch.object(setup_alpine_proot, 'extract_file_from_deb', return_value=b'libtalloc.so.2\x00'), \
                    mock.patch('builtins.print'):
                setup_alpine_proot.download_and_setup(['arm64-v8a'])
            self.assertEqual(rootfs.read_bytes(), b'customized rootfs must survive native updates')

    def test_all_native_dependencies_are_bundled(self):
        system_libraries = {'libc.so', 'libdl.so', 'libm.so', 'liblog.so'}
        for abi in ['arm64-v8a', 'armeabi-v7a', 'x86', 'x86_64']:
            directory = MAIN / 'jniLibs' / abi
            with self.subTest(abi=abi):
                names = {path.name for path in directory.glob('*.so')}
                self.assertIn('libproot.so', names)
                for path in directory.glob('*.so'):
                    self.assertFalse(set(needed_libraries(path)) - names - system_libraries,
                                     f'{abi}/{path.name} has unpackaged dependencies')

    def test_login_profile_terminates_and_preserves_user_profile(self):
        source = (MAIN / 'kotlin/app/gsmlg/android_shell/AndroidShellPlugin.kt').read_text()
        match = re.search(r'val profileContent = """(.*?)"""', source, re.S)
        self.assertIsNotNone(match)
        with tempfile.TemporaryDirectory() as temporary:
            directory = pathlib.Path(temporary)
            profile_d = directory / 'web_terminal.sh'
            user_profile = directory / '.profile'
            user_profile.write_text(match.group(1).replace('/root', temporary)
                                    .replace('/etc/profile.d/web_terminal.sh', str(profile_d)))
            profile_d.write_text((MAIN / 'assets/shell/profile').read_text())
            # bash bounds source nesting so a recursion fails deterministically.
            result = subprocess.run(['/bin/bash', '-c',
                'FUNCNEST=20; export HOME="$1"; . "$2"; printf "PROFILE_READY\\n"',
                'profile-test', temporary, str(profile_d)], capture_output=True, text=True, timeout=5)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn('maximum', result.stderr)
            self.assertIn('PROFILE_READY', result.stdout)
            # Alpine login shells read .profile themselves; user content survives.
            user_profile.write_text('export USER_PROFILE_SEEN=yes\n')
            result = subprocess.run(['/bin/bash', '-c',
                'export HOME="$1"; . "$2"; . "$HOME/.profile"; test "$USER_PROFILE_SEEN" = yes',
                'profile-test', temporary, str(profile_d)], capture_output=True, text=True, timeout=5)
            self.assertEqual(result.returncode, 0, result.stderr)

    def test_native_binaries_are_extracted_for_process_execution(self):
        build = (ROOT / 'android/app/build.gradle.kts').read_text()
        self.assertRegex(build, r'useLegacyPackaging\s*=\s*true')


if __name__ == '__main__':
    unittest.main()
