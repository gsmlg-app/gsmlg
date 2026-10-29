import pathlib
import subprocess
import sys
import tempfile
import unittest


@unittest.skipIf(sys.platform == 'win32', 'Unix PTY lifecycle')
class NativeLifecycleTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.directory = tempfile.TemporaryDirectory(prefix='pty-native-')
        cls.addClassCleanup(cls.directory.cleanup)
        cls.binary = pathlib.Path(cls.directory.name) / 'native_lifecycle'
        source = pathlib.Path(__file__).with_name('native_lifecycle_test.c')
        subprocess.run([
            'clang', '-D_GNU_SOURCE', '-pthread', '-g',
            str(source), '-o', str(cls.binary),
            *(['-Wl,-export_dynamic', '-ldl'] if sys.platform != 'darwin' else []),
        ], check=True, capture_output=True, text=True)

    def test_real_native_lifecycle(self):
        for scenario in [
            'natural', 'ack', 'exec', 'cwd', 'close',
            'reader-failure', 'waiter-failure', 'fd-failure',
            'background-output', 'slow-background-output', 'full-write',
            'group-ownership',
        ]:
            with self.subTest(scenario=scenario):
                result = subprocess.run(
                    [str(self.binary), scenario], timeout=12,
                    capture_output=True, text=True,
                )
                self.assertEqual(result.returncode, 0, result.stderr)

    def test_dart_native_lifecycle(self):
        root = pathlib.Path(__file__).resolve().parents[3]
        if sys.platform == 'darwin':
            library = pathlib.Path(self.directory.name) / 'flutter_pty.framework' / 'flutter_pty'
            library.parent.mkdir(exist_ok=True)
        else:
            library = pathlib.Path(self.directory.name) / 'lib' / 'libflutter_pty.so'
            library.parent.mkdir(exist_ok=True)
        subprocess.run([
            'clang', '-D_GNU_SOURCE', '-shared', '-fPIC', '-pthread',
            str(root / 'app_plugin/pty/src/flutter_pty.c'), '-o', str(library),
        ], check=True, capture_output=True, text=True)
        script = pathlib.Path(__file__).with_name('native_lifecycle.dart').resolve()
        command = [
            'dart', '--packages=' + str(root / '.dart_tool/package_config.json'),
            str(script),
        ]
        if sys.platform != 'darwin':
            executable = pathlib.Path(self.directory.name) / 'pty_lifecycle'
            subprocess.run([
                'dart', 'compile', 'exe', str(script), '-o', str(executable),
            ], cwd=root, check=True, timeout=90, capture_output=True, text=True)
            command = [str(executable)]
        result = subprocess.run(command, cwd=self.directory.name, timeout=30,
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == '__main__':
    unittest.main()
