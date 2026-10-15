import importlib.util
import pathlib
import unittest

spec=importlib.util.spec_from_file_location('check_env',pathlib.Path(__file__).with_name('check-env.py'))
guard=importlib.util.module_from_spec(spec)
spec.loader.exec_module(guard)

class DotenvGuardTests(unittest.TestCase):
    def test_rejects_private_names_in_nested_directories(self):
        for path in ['.env','apps/web/.env.local','nested/.env.production','x/.env.test']:
            with self.subTest(path=path): self.assertTrue(guard.forbidden(path))

    def test_allows_only_explicit_sample_names(self):
        for path in ['.env.example','.env.sample','.env.template','apps/.env.production.example']:
            with self.subTest(path=path): self.assertFalse(guard.forbidden(path))

    def test_similar_names_do_not_bypass_guard(self):
        self.assertTrue(guard.forbidden('.env.example.local'))
        self.assertTrue(guard.forbidden('.env.examples'))

if __name__=='__main__': unittest.main()
