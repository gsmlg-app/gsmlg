#!/usr/bin/env python3
"""Compare/apply explicit Web Terminal mappings; no third-party Python modules."""
import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import stat
import subprocess
import sys
import tempfile


class SyncError(Exception):
    pass


def run(argv, cwd, check=True):
    result = subprocess.run(argv, cwd=cwd, capture_output=True)
    if check and result.returncode:
        raise SyncError(f"Command failed: {argv[0]} {argv[1]} (exit {result.returncode})")
    return result


def git(root, *args):
    return run(["git", *args], root).stdout


def safe_path(value):
    if not isinstance(value, str) or not value or any(ord(c) < 32 or c in "\\:" for c in value):
        raise SyncError(f"Invalid repository path: {value!r}")
    path = PurePosixPath(value)
    if path.is_absolute() or any(p.lower() in (".", "..", ".git") for p in value.split("/")) or "//" in value:
        raise SyncError(f"Unsafe repository path: {value!r}")
    return str(path)


def under(path, prefix):
    return path == prefix or path.startswith(prefix + "/")


def identity(url):
    # Accept GitHub HTTPS and SSH remote spellings; reject other hosts/transports.
    match = re.fullmatch(r"(?:https://github\.com/|git@github\.com:|ssh://git@github\.com/)([^/]+/[^/]+?)(?:\.git)?/?", url)
    return "github.com/" + match[1].lower() if match else None


def verify_repo(root, expected):
    top = Path(git(root, "rev-parse", "--show-toplevel").decode().strip()).resolve()
    if top != root.resolve():
        raise SyncError("Checkout path must be its Git repository root")
    actual = {identity(u) for u in git(root, "remote", "get-url", "--all", "origin").decode().splitlines()}
    if expected not in actual:
        raise SyncError("Repository origin identity does not match manifest")


def revision(root, rev):
    return git(root, "rev-parse", "--verify", "--end-of-options", rev + "^{commit}").decode().strip()


def tree(root, rev):
    result = {}
    for row in git(root, "ls-tree", "-rz", rev).split(b"\0"):
        if row:
            header, name = row.split(b"\t", 1)
            mode, kind, oid = header.decode().split()
            result[safe_path(name.decode())] = (mode, kind, oid)
    return result


BLOB_CACHE = {}


def preload_blobs(root, entries):
    oids = sorted({entry[2] for entry in entries if entry[1] == "blob"})
    if not oids:
        return
    result = subprocess.run(["git", "cat-file", "--batch"], cwd=root,
                            input=("\n".join(oids) + "\n").encode(), capture_output=True)
    if result.returncode:
        raise SyncError("Could not read source blobs")
    offset = 0
    for oid in oids:
        end = result.stdout.index(b"\n", offset)
        header = result.stdout[offset:end].decode().split()
        if len(header) != 3 or header[0] != oid or header[1] != "blob":
            raise SyncError("Invalid source blob response")
        size = int(header[2])
        offset = end + 1
        BLOB_CACHE[oid] = result.stdout[offset:offset + size]
        offset += size + 1


def blob(root, entry):
    if entry is None:
        return None
    mode, kind, oid = entry
    if mode not in ("100644", "100755", "120000") or kind != "blob":
        raise SyncError("Submodules and non-blob source objects require manual review")
    return BLOB_CACHE[oid], mode


def local_file(root, relative, allow_link=False):
    path = root / relative
    for part in path.parents:
        if part == root:
            break
        if part.is_symlink():
            raise SyncError(f"Symlink parent requires manual review: {relative}")
    if path.is_symlink():
        if allow_link:
            return os.fsencode(os.readlink(path)), "120000"
        raise SyncError(f"Symlink destination requires manual review: {relative}")
    if not path.exists():
        return None
    if not path.is_file():
        raise SyncError(f"Non-file destination requires manual review: {relative}")
    return path.read_bytes(), "100755" if path.stat().st_mode & stat.S_IXUSR else "100644"


def dirty(root):
    paths = set()
    for args in (("diff", "--no-renames", "--name-only", "-z"),
                 ("diff", "--cached", "--no-renames", "--name-only", "-z"),
                 ("ls-files", "--others", "--exclude-standard", "-z")):
        paths.update(p.decode() for p in git(root, *args).split(b"\0") if p)
    return paths


def merge_content(local, old, new):
    if b"\0" in local + old + new:
        return None
    with tempfile.TemporaryDirectory(prefix="web-terminal-merge-") as directory:
        paths = [Path(directory) / n for n in ("local", "old", "new")]
        for path, content in zip(paths, (local, old, new)):
            path.write_bytes(content)
        result = run(["git", "merge-file", "-p", *map(str, paths)], directory, check=False)
        return result.stdout if result.returncode == 0 else None


def lfs_pointer(value):
    if value is None:
        return None
    match = re.fullmatch(rb"version https://git-lfs.github.com/spec/v1\noid sha256:([0-9a-f]{64})\nsize ([0-9]+)\n", value[0])
    return (match[1].decode(), int(match[2])) if match else None


def compare(old, new, local):
    if old == new:
        pointer = lfs_pointer(old)
        if pointer and local and local[1] == old[1] and len(local[0]) == pointer[1] and hashlib.sha256(local[0]).hexdigest() == pointer[0]:
            return "unchanged_asset", None
        return "unchanged" if local == old else "local_deleted" if local is None else "local_only", None
    if local == new:
        return "already_current", None
    if local == old:
        return ("delete" if new is None else "add" if old is None else "update"), new
    if None in (old, new, local):
        return "conflict", None
    mode = new[1] if local[1] == old[1] else local[1] if new[1] == old[1] else None
    content = merge_content(local[0], old[0], new[0])
    if content is not None and mode:
        merged = content, mode
        return ("already_current", None) if merged == local else ("merged", merged)
    return "conflict", None


def load_manifest(root, relative):
    path = root / safe_path(relative)
    local_file(root, relative)  # Reject a symlink manifest or parent before reading.
    raw = path.read_bytes()
    data = json.loads(raw)
    if data.get("version") != 1:
        raise SyncError("Unsupported manifest version")
    if not re.fullmatch(r"[0-9a-f]{40}", data.get("baseline", "")):
        raise SyncError("Manifest baseline must be a full 40-character commit SHA")
    for side in ("source", "destination"):
        if not re.fullmatch(r"github\.com/[^/]+/[^/]+", data[side]["identity"]):
            raise SyncError("Invalid repository identity")
    return path, raw, data


# These are existing application-owned integration areas, never copied wholesale.
MANUAL_DESTINATIONS = (
    "app_lib/database", "app_lib/locale", "app_lib/secure_storage",
    "app_lib/provider", "app_lib/logging", "lib/router.dart", "lib/screens/toolbox/toolbox_routes.dart",
    "lib/screens/settings/settings_routes.dart", "lib/screens/settings/settings_screen.dart",
    "lib/screens/toolbox/toolbox_screen.dart", "lib/destination.dart", "lib/main.dart",
    "lib/app.dart", "pubspec.yaml", "pubspec.lock",
)


def inventory(data, old_tree, new_tree):
    excluded = [safe_path(e["path"]) for e in data["exclusions"]]
    mappings = []
    destinations = set()
    sources = set()
    for key, manual in (("copy_mappings", False), ("shared_merge_mappings", True)):
        for item in data[key]:
            source, destination = safe_path(item["source"]), safe_path(item["destination"])
            if not manual and any(under(destination, p) or under(p, destination) for p in MANUAL_DESTINATIONS):
                raise SyncError(f"Shared destination must use manual merge mapping: {destination}")
            files = item.get("files")
            if files is not None:
                for name in files:
                    safe_path(name)
            # Explicit files document the initial copy. New files under the same
            # mapped root are deliberately surfaced for dependency/license review.
            names = sorted(p for p in old_tree.keys() | new_tree.keys()
                           if under(p, source) and not any(under(p, e) for e in excluded))
            for name in names:
                suffix = name[len(source):].lstrip("/")
                dest = destination + ("/" + suffix if suffix else "")
                safe_path(dest)
                if dest in destinations or name in sources:
                    raise SyncError("Overlapping source/destination mappings")
                destinations.add(dest)
                sources.add(name)
                mappings.append((name, dest, manual))
    for license_entry in data.get("licenses", []):
        safe_path(license_entry["source"])
        safe_path(license_entry["destination"])
    return mappings


def synchronize(args):
    root = Path(args.repo).resolve()
    source = Path(args.source).resolve() if args.source else root.parent / "web-terminal"
    manifest_path, original_manifest, data = load_manifest(root, args.manifest)
    verify_repo(root, data["destination"]["identity"])
    verify_repo(source, data["source"]["identity"])
    old_rev, new_rev = revision(source, data["baseline"]), revision(source, args.to)
    old_tree, new_tree = tree(source, old_rev), tree(source, new_rev)
    mappings = inventory(data, old_tree, new_tree)
    preload_blobs(source, [entry for src, _, _ in mappings
                           for entry in (old_tree.get(src), new_tree.get(src)) if entry])
    source_dirty, local_dirty = dirty(source), dirty(root)
    source_hashes, rows, writes, blockers = {}, [], [], []
    known_hashes = data.get("source_files", {})
    acknowledged = {safe_path(p) for p in args.ack_manual}
    manual_changes = set()
    for src, dst, manual in mappings:
        row = {"source": src, "destination": dst, "manual": manual}
        try:
            old, new = blob(source, old_tree.get(src)), blob(source, new_tree.get(src))
            link = any(value and value[1] == "120000" for value in (old, new))
            local = local_file(root, dst, allow_link=link)
            if old is not None and src in known_hashes and hashlib.sha256(old[0]).hexdigest() != known_hashes[src]:
                raise SyncError("Recorded source hash does not match baseline")
            if new is not None:
                source_hashes[src] = hashlib.sha256(new[0]).hexdigest()
            action, content = compare(old, new, local)
            asset = any(value and value[0].startswith(b"version https://git-lfs.github.com/spec/v1\n") for value in (old, new))
            if asset:
                row["lfs_asset"] = True
            if link:
                row["symlink_asset"] = True
            if (manual or asset or link) and old != new:
                manual_changes.add(src)
                action, content = ("manual_acknowledged" if src in acknowledged else "manual_merge"), None
                if src not in acknowledged:
                    blockers.append(src)
            row["action"] = action
            if src in source_dirty:
                row["source_dirty"] = True
                blockers.append(src)
            if dst in local_dirty:
                row["destination_dirty"] = True
                if content is not None or action == "delete":
                    row["action"] = "blocked_dirty"
                    blockers.append(dst)
            if action == "conflict":
                blockers.append(src)
            if content is not None or action == "delete":
                writes.append((dst, local, content))
        except SyncError as error:
            row.update(action="unsafe", detail=str(error))
            blockers.append(src)
        rows.append(row)
    if acknowledged - manual_changes:
        raise SyncError("--ack-manual must name an affected shared source file")
    report = {"baseline": old_rev, "target": new_rev, "mode": "apply" if args.apply else "report",
              "files": rows, "blockers": sorted(set(blockers)), "baseline_advanced": False}
    if not args.apply:
        return report, 0
    if not args.verify:
        raise SyncError("Apply requires at least one explicit --verify JSON argv command")
    commands = [json.loads(command) for command in args.verify]
    if any(not isinstance(c, list) or not c or any(not isinstance(a, str) or not a or "\0" in a for a in c) for c in commands):
        raise SyncError("Each --verify must be a nonempty JSON array of command arguments")
    if blockers:
        return report, 2
    # Recheck every file before writing so a concurrent edit is not overwritten.
    for dst, before, after in writes:
        if local_file(root, dst) != before:
            raise SyncError(f"Destination changed during comparison: {dst}")
    for dst, before, after in writes:
        path = root / dst
        if after is None:
            path.unlink()  # Leaf file only. Never remove directories.
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(after[0])
            path.chmod(0o755 if after[1] == "100755" else 0o644)
    report["verification"] = []
    for command in commands:
        # Only argv supplied by the caller is executable; never read commands
        # from source files or manifest, and never invoke a shell implicitly.
        outcome = run(command, root, check=False)
        report["verification"].append({"argv": command, "exit_code": outcome.returncode})
        if outcome.returncode:
            report["verification_failed"] = True
            return report, 3
    if manifest_path.read_bytes() != original_manifest:
        raise SyncError("Manifest changed during synchronization; baseline left unchanged")
    if new_rev != old_rev or source_hashes != known_hashes:
        data["baseline"] = new_rev
        data["source_files"] = source_hashes
        # A successful update records current inventory, including added/deleted
        # files. Rename appears as an explicit safe delete/add pair.
        for mapping in data["copy_mappings"]:
            prefix = mapping["source"]
            if prefix in old_tree or prefix in new_tree:
                mapping.pop("files", None)
            else:
                mapping["files"] = sorted(src[len(prefix):].lstrip("/") for src, _, manual in mappings
                                          if not manual and under(src, prefix) and src in new_tree)
        with tempfile.NamedTemporaryFile(mode="w", dir=manifest_path.parent, delete=False) as temporary:
            temporary.write(json.dumps(data, indent=2) + "\n")
            temporary_name = temporary.name
        os.replace(temporary_name, manifest_path)
        report["baseline_advanced"] = new_rev != old_rev
    return report, 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", default=str(Path(__file__).resolve().parents[4]))
    parser.add_argument("--source", help="Source Git root; defaults to sibling ../web-terminal")
    parser.add_argument("--manifest", default="docs/terminal/upstream-manifest.json")
    parser.add_argument("--to", default="HEAD", help="Committed source revision")
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--ack-manual", action="append", default=[], metavar="SOURCE_FILE")
    parser.add_argument("--verify", action="append", default=[], metavar="JSON_ARGV")
    args = parser.parse_args()
    try:
        report, code = synchronize(args)
        print(json.dumps(report, indent=2))
        return code
    except (SyncError, OSError, ValueError, KeyError, TypeError) as error:
        print(json.dumps({"error": str(error)}), file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
