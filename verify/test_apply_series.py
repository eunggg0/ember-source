#!/usr/bin/env python3
"""Patch application must ignore an enclosing handoff's Git environment."""
import os, subprocess, tempfile, unittest
from pathlib import Path
HERE = Path(__file__).resolve().parent
class ApplySeriesTests(unittest.TestCase):
    def test_apply_outside_git_with_inherited_repository(self):
        with tempfile.TemporaryDirectory(dir=HERE) as tmp:
            root = Path(tmp); source = root / 'source'; patches = root / 'patches'
            source.mkdir(); patches.mkdir(); (source / 'value.txt').write_text('before\n')
            (patches / 'series').write_text('# ignored comment\n\n0001-change.patch\n')
            (patches / '0001-change.patch').write_text('diff --git a/value.txt b/value.txt\n--- a/value.txt\n+++ b/value.txt\n@@ -1 +1 @@\n-before\n+after\n')
            env = {**os.environ, 'GIT_DIR': str(root / 'nonexistent.git'),
                   'GIT_WORK_TREE': str(root / 'wrong-tree'), 'GIT_INDEX_FILE': str(root / 'wrong-index')}
            result = subprocess.run(['sh', str(HERE.parent / 'scripts/apply-series.sh'), str(patches), str(source)], env=env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual((source / 'value.txt').read_text(), 'after\n')
            self.assertFalse((root / 'wrong-index').exists())
if __name__ == '__main__': unittest.main()
