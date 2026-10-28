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
