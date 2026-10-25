#!/usr/bin/env python3
"""Offline source-fetch tests: failures must not report successful verification."""
import hashlib
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

HERE = Path(__file__).resolve().parent
SCRIPT = HERE.parent / 'scripts' / 'fetch-upstream.sh'


class FetchUpstreamTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='fetch-upstream-', dir=HERE)
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        (self.root / 'scripts').mkdir()
        (self.root / 'upstream').mkdir()
        (self.root / 'bin').mkdir()
        shutil.copy2(SCRIPT, self.root / 'scripts' / SCRIPT.name)
        self.log = self.root / 'curl.log'
        fake = self.root / 'bin' / 'curl'
        fake.write_text(r"""#!/usr/bin/env python3
import os
from pathlib import Path
import sys
args = sys.argv[1:]
with open(os.environ['FAKE_CURL_LOG'], 'a') as log:
    log.write(args[-1] + '\n')
status = int(os.environ.get('FAKE_CURL_STATUS', '0'))
if status:
    sys.exit(status)
Path(args[args.index('-o') + 1]).write_bytes(os.environ['FAKE_CURL_CONTENT'].encode())
""")
        fake.chmod(0o755)
        self.env = {**os.environ,
                    'PATH': str(self.root / 'bin') + os.pathsep + os.environ['PATH'],
                    'BASE': 'https://offline.invalid/release',
                    'FAKE_CURL_LOG': str(self.log),
                    'FAKE_CURL_CONTENT': 'archive contents',
                    'FAKE_CURL_STATUS': '0'}

    def row(self, name='good.tar.xz', content='archive contents'):
        digest = hashlib.sha256(content.encode()).hexdigest()
        return f'group\t{name}\thttps://unused.invalid/{name}\t{digest}\t0\ttest\n'

    def run_fetch(self, manifest, *names):
        (self.root / 'upstream' / 'SOURCES.tsv').write_text(manifest)
        return subprocess.run(['sh', str(self.root / 'scripts' / SCRIPT.name), *names],
                              cwd=self.root, env=self.env, capture_output=True, text=True)

    def test_bad_hash_is_failure(self):
        result = self.run_fetch(self.row(content='different expected archive'))
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('BAD group/good.tar.xz', result.stdout)

    def test_download_failure_is_failure(self):
        self.env['FAKE_CURL_STATUS'] = '22'
        result = self.run_fetch(self.row())
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('download failed: good.tar.xz', result.stderr)
        self.assertFalse((self.root / 'upstream' / 'group' / 'good.tar.xz').exists())
        self.assertNotIn('ok  ', result.stdout)

    def test_good_hash_is_success(self):
        result = self.run_fetch(self.row())
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('ok  group/good.tar.xz', result.stdout)
        self.assertEqual((self.root / 'upstream' / 'group' / 'good.tar.xz').read_text(),
                         'archive contents')
        # A verified local archive must not be downloaded again.
        self.log.unlink()
        self.env['FAKE_CURL_STATUS'] = '22'
        cached = self.run_fetch(self.row())
        self.assertEqual(cached.returncode, 0, cached.stdout + cached.stderr)
        self.assertFalse(self.log.exists())

    def test_comments_blank_lines_and_filename_filter(self):
        manifest = '# group\tfile\tupstream\tsha256\tbytes\tverification\n\n'
        manifest += self.row('skip.tar.xz', 'would mismatch') + self.row('wanted.tar.xz')
        result = self.run_fetch(manifest, 'wanted.tar.xz')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.log.read_text().splitlines(),
                         ['https://offline.invalid/release/wanted.tar.xz'])
        self.assertFalse((self.root / 'upstream' / 'group' / 'skip.tar.xz').exists())


if __name__ == '__main__':
    unittest.main()
