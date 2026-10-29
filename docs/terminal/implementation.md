# Terminal integration and upstream synchronization

Last checked: 2026-10-29. Uncommitted implementation on GSMLG `main`, starting at `1d1fbfbe4fe3427b927aed8debf8b565404cc037`. Imported Web Terminal baseline: `67f4a5afb335849852da972cfb71cb5fe725c7ff`.

## Ownership and behavior

Terminal is a native-app Toolbox tool at `/toolbox/terminal`. The existing Settings screen has one Terminal Configuration group: preferences, environment variables, Shell Profiles, SSH Hosts and SSH Keys. Global theme/device/account configuration stays owned by GSMLG. Web Server sharing is outside this accepted migration scope.

`app_lib/provider/lib/src/main.dart` remains the DI authority. Its conditional native terminal dependency helper registers the repositories and BLoCs. Browser builds select an empty helper and an unsupported Terminal screen, without importing PTY FFI. Browser Toolbox and Settings hide the native feature entries. Browser compilation/runtime has not yet been verified.

`TerminalSessionBloc` owns tabs across route changes and disposes its final tab snapshot after draining pending BLoC events at app teardown. The route-owned screen owns only presentation listeners and restoration coordination. Terminal context-menu operations receive a `ContextMenuOverlay` in the native workspace. A source terminal screen is adapted rather than importing another MaterialApp or upstream application bootstrap.

The application database advances from schema 18 to 19, adding the source SSH key, SSH host and Shell Profile tables. Existing schema history, storage filename and records remain intact. SSH credentials use the existing platform Vault implementation, with separate terminal namespaces; SQLite stores opaque credential references. SSH host-key confirmation/pinning remains in the source connection flow. This migration does not import another installed application's private database/keychain.

Terminal-owned packages, native inputs and package/vendor notices retain source paths where practical. Constraints align to GSMLG's existing Equatable 3, Duskmoon 2 and secure-storage 11 ecosystem. The source whole-app Settings root, duplicate theme/device settings, unrelated macOS developer UI and their tests are excluded; no required terminal tests were removed to hide failures. Drift/localization/plugin registrants are generated from the integrated sources.

Android's host Gradle configuration enables legacy JNI extraction because bundled shell executables run from nativeLibraryDir. The iOS Podfile incorporates upstream's command dictionary and Python embedding hooks. macOS Debug, Android ARM64 Debug and iOS simulator Debug builds passed; platform runtime acceptance is separate. Existing macOS sandbox entitlements have not been changed; the built app reproduces an App Sandbox incompatibility in upstream PTY child setup (issue #8 below).

## Synchronization

Use `.agents/skills/sync-web-terminal/SKILL.md`. The companion helper defaults to a read-only report against `../web-terminal`; `docs/terminal/upstream-manifest.json` records source identity, full baseline, path mappings, shared manual-merge boundaries, exclusions, source hashes and actual package/vendor licenses.

Native-screen source maps to `terminal_native_screen.dart`; the conditional export and unsupported-screen wrapper are GSMLG-owned. Provider, database, vault, localization, host build configuration and logging integrations require explicit shared merges. Changed native symlinks and hydrated LFS assets require manual review; the helper does not replace binaries with LFS pointers. Before an iOS build, provision the ignored Python framework support template using the upstream pinned setup script or the identical same-version source installation. The initial tracked-file import omitted this input; copying the upstream template byte-for-byte resolved the simulator packaging failure. Explicit apply requires trusted verification commands. Conflicts/dirty overlaps block planned writes, and failed checks leave the prior source baseline intact.

The source README claims an MIT root license but that baseline does not contain a root LICENSE. Actual package and bundled notices are recorded; no top-level license was invented. This work is not publication or distribution approval.

## Required upstream fixes

These are source limitations, not local implementations. Per repository policy, affected acceptance is stopped; no local workaround is applied. Resume after an available upstream fix is imported and its behavior verified, not merely after issue closure.

- `TODO(upstream): gsmlg-app/web-terminal#5` — [SFTP workspace action](https://github.com/gsmlg-app/web-terminal/issues/5). The menu currently displays a coming-soon snackbar. Actual SFTP workspace acceptance is blocked.
- `TODO(upstream): gsmlg-app/web-terminal#6` — [initial profile readiness](https://github.com/gsmlg-app/web-terminal/issues/6). Source startup may open the first tab before profiles load when restoration is disabled; default-profile creation/load events also lack completion ordering. Configured first-session acceptance is blocked.
- `TODO(upstream): gsmlg-app/web-terminal#7` — [mobile local-tab restoration](https://github.com/gsmlg-app/web-terminal/issues/7). Source serialization omits AndroidHostSpec and IosHostSpec, losing mobile local-tab metadata. Mobile restoration acceptance is blocked.

- `TODO(upstream): gsmlg-app/web-terminal#8` — [sandboxed macOS local PTY](https://github.com/gsmlg-app/web-terminal/issues/8). A native probe with the unchanged GSMLG DebugProfile entitlements confirms `setsid` succeeds but `ioctl(TIOCSCTTY)` fails with errno 1 (`EPERM`); the child exits 127. An unsandboxed control succeeds. The built app exit callback independently reports 127. The source host disables App Sandbox; GSMLG preserves its existing policy. Local-shell acceptance is stopped pending compatible upstream support and child-setup error propagation.

## Verification evidence and limits

Passed:

- Scoped Dart analysis of imported terminal/core/shared/UI/provider sources and added UI tests.
- Database: 8 Flutter tests, including schema 18→19 upgrade preserving a real chat record, SSH/profile persistence after reopen, fresh creation, and existing earlier migration tests.
- Vault/SSH credential storage: 36 Flutter tests, including reference storage, failure behavior and existing platform-vault compatibility coverage.
- Terminal tab BLoC: 71 Flutter tests; terminal settings: 54; Shell Profile: 78; terminal core: 209.
- Provider session lifecycle: 2 Flutter tests passed, covering pending-event drain at app teardown and session preservation across route stop/start followed by explicit close.
- Sync helper: 22 behavioral tests; skill frontmatter validator; independent real unchanged-source report with zero blockers and no baseline advancement.
- Unix PTY: 2 real native/Dart lifecycle tests. Android: 7 artifact/rootfs validation tests, 6 rootfs-builder tests, and 5 APK contract tests. These do not establish an installed Android runtime.
- 4,529 tracked native plugin input files matched the source checkout byte-for-byte when audited. The sync report independently verifies hydrated LFS assets against pointer digests.
- Expanded native regression suite: 902 passed, including terminal screens/navigation/right-click, terminal hosts/host-key handling, SSH host/key BLoCs, tab widgets and terminal settings widgets.
- macOS Debug, Android ARM64 Debug and iOS simulator Debug app builds passed. Android APK rootfs hashes match all four source architecture archives; proot libraries and `extractNativeLibs=true` were verified.
- Independent source review found no further actionable integration regression in the reviewed unaffected scope. Scoped whitespace checks pass.

Failures/blockers:

- The initial root Flutter test attempt failed before execution with disk errno 28. After authorized cleanup, the expanded native suite passed all 902 tests across terminal screens, terminal hosts, SSH host/key BLoCs, tab widgets and terminal settings widgets. Right-click and SSH-shortcut test fixtures were corrected to flush a scheduled text write and avoid a real network connection; their assertions remain intact. Browser-specific execution still requires a browser runner.
- The user explicitly authorized deletion of `.dart_tool/hooks_runner/shared/duskmoon_highlight/build`; only that cache was removed, increasing free space from about 352 MiB to 12 GiB. Rebuilt native caches and platform outputs consume part of that space. After builds completed, the cache regenerated by this verification run was removed again at the same authorized path; built app/APK artifacts were retained. Final free space was approximately 5.6 GiB. No other pre-existing cache was removed.
- SSH suite: 1,001 passed, 1 skipped, 1 failed. The unchanged upstream handshake-abort test connects to `bing.com:443`; local DNS resolution failed and the test timed out. This is not reported as a fully passing suite, and the test was not weakened.
- `dart run dependency_validator` traverses the workspace but crashes on the existing Mason path `bricks/native_plugin/__brick__/{{name.snakeCase()}}/**` with `unexpected "("`. That path exists in the starting HEAD and was not modified. Validator warnings are not interpreted as a passing workspace validation.
- macOS Debug and Android ARM64 Debug builds passed. The APK contains PTY, proot and architecture-specific rootfs assets. macOS Toolbox → Terminal and the complete Settings group were observed in the built app. A local session rendered a blank terminal and exited 127. After unlocking and gaining exclusive window access, a VM breakpoint captured that code; an isolated sandbox/unsandboxed syscall comparison confirmed the TIOCSCTTY/EPERM boundary tracked in #8. Temporary breakpoints were removed. Existing sandbox entitlements were preserved. The iOS simulator build initially failed because the ignored Python support template was missing; after reusing the same-version upstream template byte-for-byte (SHA256 `d2acfc1ff96350edf4ce22128ede5a2619aa9528f75a47a325bf701900a09525`), the retry passed. The attempted pinned archive download was canceled before installation because that existing upstream input was available. Generated CocoaPods projects, workspace links and lockfiles are retained; pre-existing Swift package pins removed by Xcode were restored. Pixel Fold local-shell evidence is recorded below. Full soft-keyboard/navigation acceptance, SSH/SFTP, mobile restoration, and Linux/Windows app builds remain unverified. Chrome boundary-test compilation failed in pre-existing Chat/local-model native imports (`app_lib/chat/lib/src/services/minicpm_title_backend.dart` and `third_party/lib_litert_lm` use `dart:ffi`); these modules were not modified.

## Pixel Fold physical-device verification (2026-10-29)

- Physical Google Pixel Fold (`felix`, serial `37011FDH8119SS`), Android 17 / API 37, ARM64, unfolded display.
- Updated existing `org.gsmlg.app` using `adb install -r` with the built ARM64 Debug APK: `Success`. Existing/new signing certificate SHA-256 matched (`ef20bb6e151a315e9524af3fb0c0d7c87d4d527186788847a94ad69eb53e7a62`). No uninstall or data clear.
- Integrated Terminal rendered a local zsh prompt. Controlled UI-driven commands returned `/home/gao` for `pwd`, `PIXELFOLDOK` for `echo PIXELFOLDOK`, and `aarch64` for `uname -m`. App process 28093 owned proot 28278 / zsh 28285 during verification. Crash log buffer was empty when checked; this is not proof against every runtime error.
- CUA operated an official scrcpy mirror. Bulk text injection lost characters in SDK and UHID modes; individual key events produced the exact commands and outputs above. Mirror clicks did not reliably target displayed controls (a launcher click selected an adjacent app). This transport limitation is not established as an app defect.
- Session creation/switch/close, Settings navigation, direct soft-keyboard typing and folded outer-display behavior were not accepted in this run. No extra terminal session or test filesystem data was created. Mobile cold-start local-tab restoration remains blocked by upstream #7.
- Updated app and existing data retained. Installation log: `/tmp/gsmlg-pixel-fold-install.txt`.

No branch/worktree, commit, push, release or deployment was performed.
