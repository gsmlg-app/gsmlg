---
name: sync-web-terminal
description: Compare and update the Web Terminal code migrated into GSMLG using the recorded upstream baseline, preserving local adaptations and manually merged shared integrations.
---

Use for maintenance of this migration, not importing another app or enabling its Web Server. Read `docs/terminal/upstream-manifest.json` and the accepted migration design in `docs/superpowers/specs/2026-10-28-web-terminal-migration-design.md`.

Run from the GSMLG root. The Python standard-library helper defaults to a read-only report, the sibling `../web-terminal` checkout, and its committed `HEAD`:

```bash
python3 .agents/skills/sync-web-terminal/scripts/sync_web_terminal.py
```

Use `--source <checkout>` and `--to <commit>` when needed. It verifies both origin identities and the full baseline commit. Uncommitted source files are reported; they are never used as the update snapshot. Report output is JSON; large native inventories can be redirected to a temporary report file.

Review changed files and the complete import/dependency closure, native build inputs, tests, constraints and licenses. `copy_mappings` records migrated roots and their baseline `files` inventory. New upstream files under those roots appear automatically. `exclusions` are exact source paths or subtrees; inspect whether exclusions still match the accepted feature scope. A rename appears as a delete/add pair, so local adaptations to the old path can block the update.

Before modifying existing application symbols, run the repository-required GitNexus impact analysis. Preserve unrelated dirty changes. The helper blocks writes to dirty mapped files, conflicting content, unsafe paths, and symlink parents. It can merge disjoint text edits using Git's three-way merge; conflicting files are left untouched. Resolve conflicts manually and rerun the report. A deletion removes only an unchanged leaf file, never a directory.

Shared database, locale, vault, provider and application route integrations always use `shared_merge_mappings`; merge them by hand. Source schema versions, generated Drift/localization files, app bootstrap and whole Settings roots must not replace GSMLG versions. Screen wrappers and package metadata have recorded local adaptations that must survive updates. The source terminal screen maps to `terminal_native_screen.dart`; GSMLG owns the conditional `terminal_screen.dart` export and unsupported-platform screen. Native DI maps into `terminal_dependencies_native.dart`; preserve MainProvider’s conditional browser stub and keep `dart:ffi` outside the browser import graph. Native Podfile/Gradle hooks also remain manual merges. Review `review_roots` for new source files outside explicit mappings.

Tracked symlinks are compared using their link text without following them. Changed symlinks and LFS assets require manual handling. The helper never writes a source LFS pointer into a hydrated destination asset or creates/retargets a symlink. Materialize and inspect native assets through trusted Git LFS/native procedures, verify their pointer SHA256 and size, preserve framework layout, and review licenses/build reproducibility before acknowledging those source files.

Before an iOS build, check that `app_plugin/ios_shell/ios/Frameworks/Python.xcframework/build/iOS-dylib-Info-template.plist` exists. The framework's `build/` support directory is ignored by Git and is absent from a tracked-files-only import. Provision it using the upstream `app_plugin/ios_shell/scripts/download_python.sh`, which pins and verifies the Python support archive, or reuse the identical support input from the source checkout's same-version framework. Do not invent a replacement plist or remove the Python embedding step. The initial migration reused that upstream template byte-for-byte (SHA256 `d2acfc1ff96350edf4ce22128ede5a2619aa9528f75a47a325bf701900a09525`); recheck provenance when the Python version changes. This ignored provisioning input is separate from the manifest's tracked source hashes.

Apply only within the user's authorized update scope. After manually resolving affected shared files/assets, pass one `--ack-manual <source-file>` per reviewed change. Supply required verification as explicit trusted JSON argument arrays; the manifest cannot supply executable commands. Example (substitute the relevant feature analysis/tests/build commands):

```bash
python3 .agents/skills/sync-web-terminal/scripts/sync_web_terminal.py --to <commit> --apply \
  --verify '["python3","-m","unittest","discover","-s",".agents/skills/sync-web-terminal/tests","-v"]' \
  --verify '["melos","run","validate-dependencies"]'
```

Choose verification for the actual diff: terminal regression tests, database upgrade/fresh-install preservation, credentials/host-key checks, navigation/session lifecycle, formatting, analysis, dependency validation, and available native builds/runtime checks. The example helper tests alone do not validate Flutter behavior. Verification runs without an implicit shell; wrap a shell explicitly only for a reviewed command that needs it. Captured command output is not printed, so rerun a failed check directly for diagnostics without exposing secrets.

All planned writes are blocked if any conflict, dirty overlap, missing manual acknowledgment or unsafe source object remains. If verification fails after application, file changes remain for review and the old baseline stays intact. Fix the failure within scope, then rerun; already-applied updates are recognized. The helper atomically advances `baseline`, `source_files` (SHA256 of Git blob bytes, including LFS pointers/link text), and copied file inventories only after every supplied check succeeds. Repeating a successful revision is a no-op. Keep test/runtime limits in the task report; never claim a native runtime from build evidence.

Use `upstream-issue-routing` for evidenced dependency issues covered by repository policy. A confirmed upstream blocker stops the affected update; do not add a local workaround. The manifest links current upstream blockers: [SFTP placeholder (#5)](https://github.com/gsmlg-app/web-terminal/issues/5), [first-tab profile readiness (#6)](https://github.com/gsmlg-app/web-terminal/issues/6), [mobile restore metadata (#7)](https://github.com/gsmlg-app/web-terminal/issues/7), and [sandboxed macOS local PTY (#8)](https://github.com/gsmlg-app/web-terminal/issues/8). Preserve GSMLG macOS sandbox entitlements; source host entitlements disable the sandbox and must not replace them. Recheck each issue and source revision; resume the affected capability only after the upstream fix is available, the dependency is updated within scope, and its behavior is verified as recorded in the manifest. The skill grants no branch/worktree, commit, push, upstream code edit or publication authorization.

Validate helper behavior and skill metadata after changing this skill:

```bash
python3 -m unittest discover -s .agents/skills/sync-web-terminal/tests -v
python3 ~/.codex/skills/.system/skill-creator/scripts/quick_validate.py .agents/skills/sync-web-terminal
```
