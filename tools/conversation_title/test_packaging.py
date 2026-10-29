"""Small deterministic checks for the distribution gate; no model download."""
import hashlib
import io
import unittest
from contextlib import redirect_stdout
from unittest.mock import patch

import verify_package


class PackageAuditTest(unittest.TestCase):
    def setUp(self):
        self.model = b'pinned model fixture'
        self.manifest = dict(filename='fixture.gguf', size=len(self.model),
                             sha256=hashlib.sha256(self.model).hexdigest())
        self.files = {
            'assets/models/fixture.gguf': self.model,
            'assets/models/LICENSE': b'Apache-2.0',
            'assets/models/NOTICE': b'OpenBMB',
            'lib/arm64-v8a/liblib_llama_cpp_android.so': b'native fixture',
        }

    def audit(self):
        with patch.object(verify_package, 'MANIFEST', self.manifest), redirect_stdout(io.StringIO()):
            verify_package.audit([(name, lambda data=data: io.BytesIO(data))
                                  for name, data in self.files.items()])

    def test_valid_package(self):
        self.audit()

    def test_windows_directory_package(self):
        del self.files['lib/arm64-v8a/liblib_llama_cpp_android.so']
        self.files['lib_llama_cpp_windows.dll'] = b'native fixture'
        for name in ['msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll']:
            self.files[name] = b'compiler redistributable fixture'
        self.files = {name.replace('/', '\\'): data for name, data in self.files.items()}
        self.audit()

    def test_windows_requires_each_msvc_runtime(self):
        self.files['lib_llama_cpp_windows.dll'] = b'native fixture'
        runtimes = ['msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll']
        for name in runtimes:
            self.files[name] = b'compiler redistributable fixture'
        for name in runtimes:
            with self.subTest(missing=name):
                data = self.files.pop(name)
                with self.assertRaisesRegex(ValueError, name):
                    self.audit()
                self.files[name] = data

    def test_windows_runtime_must_be_next_to_inference_library(self):
        self.files['lib_llama_cpp_windows.dll'] = b'native fixture'
        for name in ['msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll']:
            self.files['unrelated/' + name] = b'compiler redistributable fixture'
        with self.assertRaisesRegex(ValueError, 'msvcp140.dll'):
            self.audit()

    def test_windows_archive_prefix_and_case_insensitive_runtime_names(self):
        self.files['lib_llama_cpp_windows.dll'] = b'native fixture'
        for name in ['MSVCP140.DLL', 'VCRUNTIME140.DLL', 'VCRUNTIME140_1.DLL']:
            self.files[name] = b'compiler redistributable fixture'
        self.files = {'release/' + name: data for name, data in self.files.items()}
        self.audit()

    def test_windows_corruption_still_fails(self):
        self.files['assets/models/fixture.gguf'] = b'x' * len(self.model)
        self.files = {name.replace('/', '\\'): data for name, data in self.files.items()}
        with self.assertRaisesRegex(ValueError, 'SHA-256 mismatch'):
            self.audit()

    def test_missing_or_duplicate_model(self):
        del self.files['assets/models/fixture.gguf']
        with self.assertRaisesRegex(ValueError, 'exactly one'):
            self.audit()
        self.files['assets/models/fixture.gguf'] = self.model
        self.files['duplicate/fixture.gguf'] = self.model
        with self.assertRaisesRegex(ValueError, 'exactly one'):
            self.audit()

    def test_same_size_corruption(self):
        self.files['assets/models/fixture.gguf'] = b'x' * len(self.model)
        with self.assertRaisesRegex(ValueError, 'SHA-256 mismatch'):
            self.audit()

    def test_missing_notice(self):
        del self.files['assets/models/NOTICE']
        with self.assertRaisesRegex(ValueError, 'NOTICE'):
            self.audit()

    def test_missing_inference_library(self):
        del self.files['lib/arm64-v8a/liblib_llama_cpp_android.so']
        with self.assertRaisesRegex(ValueError, 'native library'):
            self.audit()


if __name__ == '__main__':
    unittest.main()
