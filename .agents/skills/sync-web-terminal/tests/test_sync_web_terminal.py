"""Behavioral contract tests using ordinary disposable Git repositories."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/sync_web_terminal.py"


def git(root, *args):
    result = subprocess.run(["git", *args], cwd=root, capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError(f"Fixture git {args[0]} failed: {result.stderr.strip()}")
    return result.stdout.strip()


def write(root, path, value):
    target = root / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(value)


class SyncTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="sync-web-terminal-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.src, self.dst = self.root / "web-terminal", self.root / "gsmlg"
        for root, name in ((self.src, "web-terminal"), (self.dst, "gsmlg")):
            root.mkdir()
            git(root, "init", "-q")
            git(root, "config", "user.email", "fixture@example.invalid")
            git(root, "config", "user.name", "Fixture")
            git(root, "remote", "add", "origin", f"https://github.com/gsmlg-app/{name}.git")
        self.initial = "one\ntwo\nthree\nfour\nfive\nsix\nseven\neight\nnine\nten\n"
        write(self.src, "feature/file.txt", self.initial)
        self.baseline = self.commit(self.src)
        write(self.dst, "feature/file.txt", self.initial)
        self.manifest = self.dst / "docs/terminal/upstream-manifest.json"
        self.data = {
            "version": 1,
            "source": {"identity": "github.com/gsmlg-app/web-terminal"},
            "destination": {"identity": "github.com/gsmlg-app/gsmlg"},
            "baseline": self.baseline,
            "copy_mappings": [{"source": "feature", "destination": "feature", "files": ["file.txt"]}],
            "shared_merge_mappings": [], "exclusions": [], "licenses": [],
            "source_files": {"feature/file.txt": hashlib.sha256(self.initial.encode()).hexdigest()},
        }
        self.save()
        self.commit(self.dst)

    def save(self):
        write(self.dst, str(self.manifest.relative_to(self.dst)), json.dumps(self.data))

    def commit(self, root):
        git(root, "add", "--all")
        git(root, "commit", "-qm", "fixture")
        return git(root, "rev-parse", "HEAD")

    def invoke(self, *args):
        result = subprocess.run([sys.executable, str(SCRIPT), "--repo", str(self.dst),
                                 "--source", str(self.src), *args], capture_output=True, text=True)
        return result.returncode, json.loads(result.stdout or result.stderr)

    def apply(self, *args, success=True):
        verify = json.dumps([sys.executable, "-c", "raise SystemExit(0)" if success else "raise SystemExit(7)"])
        return self.invoke("--apply", "--verify", verify, *args)

    def test_unchanged_report_and_repeated_apply_are_noops(self):
        before = self.manifest.read_bytes()
        code, result = self.invoke()
        self.assertEqual(code, 0)
        self.assertEqual(result["files"][0]["action"], "unchanged")
        self.assertEqual(self.apply()[0], 0)
        self.assertEqual(self.apply()[0], 0)
        self.assertEqual(self.manifest.read_bytes(), before)

    def test_report_does_not_mutate_and_apply_advances_after_success(self):
        write(self.src, "feature/file.txt", "updated\n")
        target = self.commit(self.src)
        self.assertEqual(self.invoke()[1]["files"][0]["action"], "update")
        self.assertEqual((self.dst / "feature/file.txt").read_text(), self.initial)
        code, result = self.apply()
        self.assertEqual(code, 0)
        self.assertTrue(result["baseline_advanced"])
        self.assertEqual(json.loads(self.manifest.read_text())["baseline"], target)
        self.assertEqual((self.dst / "feature/file.txt").read_text(), "updated\n")
        self.assertEqual(self.apply()[0], 0)

    def test_overlapping_local_edit_is_preserved(self):
        write(self.dst, "feature/file.txt", "local\n")
        self.commit(self.dst)
        write(self.src, "feature/file.txt", "upstream\n")
        self.commit(self.src)
        code, result = self.apply()
        self.assertEqual(code, 2)
        self.assertEqual(result["files"][0]["action"], "conflict")
        self.assertEqual((self.dst / "feature/file.txt").read_text(), "local\n")
        self.assertEqual(json.loads(self.manifest.read_text())["baseline"], self.baseline)

    def test_disjoint_local_adaptation_merges_and_failed_verification_retry_works(self):
        local = self.initial.replace("one\n", "local\n")
        write(self.dst, "feature/file.txt", local)
        self.commit(self.dst)
        write(self.src, "feature/file.txt", self.initial.replace("ten\n", "upstream\n"))
        target = self.commit(self.src)
        self.assertEqual(self.apply(success=False)[0], 3)
        merged = (self.dst / "feature/file.txt").read_text()
        self.assertIn("local\n", merged)
        self.assertIn("upstream\n", merged)
        self.assertEqual(self.apply()[0], 0)
        self.assertEqual(json.loads(self.manifest.read_text())["baseline"], target)

    def test_upstream_delete_conflicts_with_local_modification(self):
        write(self.dst, "feature/file.txt", "local\n")
        self.commit(self.dst)
        (self.src / "feature/file.txt").unlink()
        self.commit(self.src)
        self.assertEqual(self.apply()[0], 2)
        self.assertEqual((self.dst / "feature/file.txt").read_text(), "local\n")

    def test_add_delete_rename_and_unrelated_dirty_file(self):
        (self.src / "feature/file.txt").rename(self.src / "feature/renamed.txt")
        write(self.src, "feature/added.txt", "added\n")
        self.commit(self.src)
        write(self.dst, "unrelated.txt", "keep dirty\n")
        code, _ = self.apply()
        self.assertEqual(code, 0)
        self.assertFalse((self.dst / "feature/file.txt").exists())
        self.assertEqual((self.dst / "feature/renamed.txt").read_text(), self.initial)
        self.assertEqual((self.dst / "feature/added.txt").read_text(), "added\n")
        self.assertEqual((self.dst / "unrelated.txt").read_text(), "keep dirty\n")
        self.assertTrue((self.dst / "feature").is_dir())

    def test_dirty_destination_update_is_blocked(self):
        write(self.dst, "feature/file.txt", self.initial.replace("one", "local"))
        write(self.src, "feature/file.txt", self.initial.replace("ten", "upstream"))
        self.commit(self.src)
        code, result = self.apply()
        self.assertEqual(code, 2)
        self.assertEqual(result["files"][0]["action"], "blocked_dirty")

    def test_failed_verification_keeps_baseline_and_retry_can_finish(self):
        write(self.src, "feature/file.txt", "upstream\n")
        target = self.commit(self.src)
        code, result = self.apply(success=False)
        self.assertEqual(code, 3)
        self.assertFalse(result["baseline_advanced"])
        self.assertEqual(json.loads(self.manifest.read_text())["baseline"], self.baseline)
        self.assertEqual(self.apply()[0], 0)
        self.assertEqual(json.loads(self.manifest.read_text())["baseline"], target)

    def test_path_traversal_is_rejected_without_writing(self):
        for path in ("../escape", "/tmp/escape", ".git/config", "feature/../../escape", "feature\\escape", "C:/escape", "feature/alternate:stream"):
            with self.subTest(path=path):
                self.data["copy_mappings"][0]["destination"] = path
                self.save()
                self.assertEqual(self.apply()[0], 1)
        self.assertFalse((self.root / "escape").exists())

    def test_bad_source_identity_is_rejected(self):
        git(self.src, "remote", "set-url", "origin", "https://github.com/attacker/other.git")
        code, result = self.apply()
        self.assertEqual(code, 1)
        self.assertIn("identity", result["error"])

    def test_bad_destination_identity_is_rejected(self):
        git(self.dst, "remote", "set-url", "origin", "https://github.com/attacker/other.git")
        self.assertEqual(self.apply()[0], 1)

    def test_source_symlink_and_destination_symlink_never_followed(self):
        (self.src / "feature/link").symlink_to("/etc/passwd")
        self.commit(self.src)
        self.assertEqual(self.apply()[0], 2)
        self.assertFalse((self.dst / "feature/link").exists())
        (self.src / "feature/link").unlink()
        self.commit(self.src)
        (self.dst / "feature/file.txt").unlink()
        outside = self.root / "outside"
        outside.write_text("private\n")
        (self.dst / "feature/file.txt").symlink_to(outside)
        self.assertEqual(self.apply()[0], 2)
        self.assertEqual(outside.read_text(), "private\n")

    def test_existing_symlinks_compare_without_following_and_updates_require_ack(self):
        (self.src / "feature/link").symlink_to("file.txt")
        baseline = self.commit(self.src)
        (self.dst / "feature/link").symlink_to("file.txt")
        self.data["baseline"] = baseline
        self.save()
        self.commit(self.dst)
        code, report = self.invoke()
        self.assertEqual(code, 0)
        self.assertEqual(report["blockers"], [])
        self.assertEqual(self.apply()[0], 0)
        (self.src / "feature/link").unlink()
        (self.src / "feature/link").symlink_to("../outside")
        self.commit(self.src)
        self.assertEqual(self.apply()[0], 2)
        self.assertEqual(self.apply("--ack-manual", "feature/link")[0], 0)
        self.assertEqual((self.dst / "feature/link").readlink(), Path("file.txt"))

    def test_single_file_mapping_remains_usable_after_baseline_advance(self):
        self.data["copy_mappings"] = [{"source": "feature/file.txt", "destination": "feature/file.txt"}]
        self.save()
        self.commit(self.dst)
        write(self.src, "feature/file.txt", "updated single file\n")
        self.commit(self.src)
        self.assertEqual(self.apply()[0], 0)
        self.assertEqual(self.invoke()[0], 0)
        self.assertEqual(self.apply()[0], 0)

    def test_symlink_parent_blocks_even_a_permitted_native_link(self):
        (self.src / "feature/link").symlink_to("file.txt")
        self.data["baseline"] = self.commit(self.src)
        self.save()
        (self.dst / "feature").rename(self.dst / "actual-feature")
        (self.dst / "actual-feature/link").symlink_to("file.txt")
        (self.dst / "feature").symlink_to("actual-feature")
        code, report = self.apply()
        self.assertEqual(code, 2)
        self.assertTrue(all(row["action"] == "unsafe" for row in report["files"]))

    def test_unchanged_hydrated_lfs_asset_is_verified_by_digest(self):
        content = b"materialized native asset"
        pointer = ("version https://git-lfs.github.com/spec/v1\noid sha256:" +
                   hashlib.sha256(content).hexdigest() + "\nsize " + str(len(content)) + "\n")
        write(self.src, "feature/file.txt", pointer)
        self.data["baseline"] = self.commit(self.src)
        self.data["source_files"]["feature/file.txt"] = hashlib.sha256(pointer.encode()).hexdigest()
        write(self.dst, "feature/file.txt", content.decode())
        self.save()
        self.commit(self.dst)
        code, report = self.invoke()
        self.assertEqual(code, 0)
        self.assertEqual(report["files"][0]["action"], "unchanged_asset")
        self.assertEqual(self.apply()[0], 0)

    def test_shared_changes_require_explicit_manual_ack_and_never_copy(self):
        self.data["copy_mappings"] = []
        self.data["shared_merge_mappings"] = [{"source": "feature/file.txt", "destination": "feature/file.txt"}]
        self.save()
        self.commit(self.dst)
        write(self.src, "feature/file.txt", "upstream\n")
        self.commit(self.src)
        self.assertEqual(self.apply()[0], 2)
        self.assertEqual(self.apply("--ack-manual", "feature/file.txt")[0], 0)
        self.assertEqual((self.dst / "feature/file.txt").read_text(), self.initial)

    def test_shared_package_cannot_be_copied(self):
        self.data["copy_mappings"][0]["destination"] = "app_lib/database"
        self.save()
        self.assertEqual(self.apply()[0], 1)

    def test_manifest_cannot_supply_verification_commands(self):
        marker = self.dst / "untrusted-executed"
        self.data["verification"] = [[sys.executable, "-c", f"open({str(marker)!r}, 'w').close()"]]
        self.save()
        self.assertEqual(self.invoke("--apply")[0], 1)
        self.assertFalse(marker.exists())
        self.assertEqual(self.apply()[0], 0)
        self.assertFalse(marker.exists())

    def test_lfs_changes_require_manual_ack_and_never_write_pointers(self):
        pointer = "version https://git-lfs.github.com/spec/v1\noid sha256:" + "a" * 64 + "\nsize 100\n"
        write(self.src, "feature/file.txt", pointer)
        self.commit(self.src)
        self.assertEqual(self.apply()[0], 2)
        self.assertEqual(self.apply("--ack-manual", "feature/file.txt")[0], 0)
        self.assertEqual((self.dst / "feature/file.txt").read_text(), self.initial)

    def test_hash_mismatch_blocks_apply(self):
        self.data["source_files"]["feature/file.txt"] = "0" * 64
        self.save()
        self.assertEqual(self.apply()[0], 2)

    def test_dirty_source_is_reported_and_blocks_apply(self):
        write(self.src, "feature/file.txt", "uncommitted upstream\n")
        self.assertTrue(self.invoke()[1]["files"][0]["source_dirty"])
        self.assertEqual(self.apply()[0], 2)


if __name__ == "__main__":
    unittest.main()
