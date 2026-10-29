# Web Terminal Implementation Plan

**Goal:** Integrate the approved Web Terminal feature, centralize its configuration in Settings, and provide a reproducible upstream synchronization skill.

**Architecture:** Reuse GSMLG's database, Vault, localization, provider and app shell. Import terminal-owned packages with source provenance; adapt app-level screens and preserve process/channel cleanup contracts.

**Tech stack:** Flutter, Dart workspace, BLoC, Drift, xterm, native PTY, Android Shell, ios_system.

Work in the current checkout. No Git commits, branch changes, worktrees, releases or deployments. Read the approved design in `docs/superpowers/specs/2026-10-28-web-terminal-migration-design.md`. Source Web Server sharing remains excluded from the initial scope. Use scoped-prd-execution for execution; bounded independent contributions may use subagent-driven-development as required by executing-plans, with coordinator-owned integrated verification.

## 1. Establish source and import boundary

- [x] Inventory tracked terminal-owned packages, native resources and licenses at the full source commit. Use GitNexus impact before modifying existing symbols and warn on elevated risk.
- [x] Copy terminal core/hosts, SSH/security/utils, terminal/SSH/profile BLoCs, terminal widgets, PTY/mobile shell plugins and flex_tabs. Exclude generated build state and unrelated app packages.
- [x] Register copied packages in `pubspec.yaml` and their root/provider dependency closures. Run `flutter pub get`; inspect resolution changes rather than upgrading unrelated packages.

## 2. Shared persistence and localization

- [x] Extend `app_lib/database/lib/src/database.dart` and terminal table files; preserve schema 18 data and advance to schema 19 with additive table creation. Generate with `dart run build_runner build` from the database package.
- [x] Add the source SSH credential repository to existing secure storage, retaining the local Vault implementation. Add targeted upgrade/reopen, credential and SSH-host-key tests.
- [x] Merge upstream terminal locale keys without replacing existing strings; regenerate with `flutter gen-l10n` from `app_lib/locale`.
- [ ] Complete all copied relevant host/BLoC suites. Database, credentials, tab/settings/profile BLoCs and terminal core passed; SSH has one unchanged network-dependent DNS failure.

## 3. User-facing integration

- [x] Adapt source terminal workspace into `lib/screens/toolbox/terminal/`, add Toolbox tile and route.
- [x] Build terminal configuration group/detail pages under `lib/screens/settings/terminal/`; register Settings routes and group. Reuse source terminal components without the upstream whole-app Settings root.
- [x] Register repositories/BLoCs in `app_lib/provider/lib/src/main.dart`. Verify navigation preserves active sessions and tab closure cleans connections.
- [ ] Execute navigation/configuration widget regressions. Native execution passed in the expanded 902-test suite after authorized cache cleanup; a browser-runner check remains.

## 4. Synchronization skill

- [x] Create `.agents/skills/sync-web-terminal/SKILL.md`, script, source manifest and behavioral tests. Record source identity, full baseline, path mappings, shared merge boundaries, exclusions and licenses.
- [x] Provide default read-only reporting, three-way comparison, conflict protection, explicit apply and baseline advancement only after successful verification.
- [x] Test unchanged source, upstream changes, overlapping local changes, deletions and failed checks without baseline advancement. Validate skill frontmatter with the bundled skill validator.

## 5. Integrated verification

- [ ] Complete integrated checks. Scoped analysis/formatting, package tests and diff review passed; native UI tests passed; dependency validation hits an existing Mason template parsing error and browser execution remains pending.
- [ ] Build/run available macOS/Android/iOS targets. Native input audits, Unix PTY lifecycle and Android artifact contracts passed; macOS/Android/iOS simulator Debug app builds passed; Pixel Fold physical-device local zsh commands passed (pwd, marker echo, uname); full soft-keyboard/navigation/folded-display acceptance remains incomplete due unreliable mirror input.
- [x] Independently review spec compliance, then code quality, address actionable findings and rerun affected checks. Record actual results and remaining limits in the design or adjacent implementation evidence.

## Acceptance status

Implementation and synchronization skill are present. Provider lifecycle tests passed (2). Full acceptance remains incomplete: upstream web-terminal issues #5, #6, #7 and #8 block their affected behavior, while macOS local-shell runtime is confirmed blocked by App Sandbox TIOCSCTTY/EPERM and remaining platform checks are incomplete; browser compilation is blocked by existing Chat/LLM FFI imports. Native UI/package regressions passed after authorized cache cleanup. See `docs/terminal/implementation.md` for actual evidence and resume conditions. No commit or delivery was performed.
