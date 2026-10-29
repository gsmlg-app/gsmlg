# Web Terminal migration into GSMLG

Date: 2026-10-28
Status: design for review; implementation has not started

## Goal and confirmed placement

Bring the terminal from `/Users/gao/Workspace/gsmlg-app/web-terminal` into GSMLG as a Toolbox tool. The user confirmed that configuration belongs in the existing Settings screen, under one new Terminal Configuration group. Reuse the common Flutter, BLoC, Duskmoon, database, localization and vault system. Do not embed a second app or copy the upstream application bootstrap.

Source checkout inspected: commit `67f4a5a` on its current branch, with no uncommitted changes. Resolve its full SHA again when creating the synchronization baseline. The GSMLG checkout was clean on `main` during inspection. Work in this checkout; no branch/worktree, commit, push, release or deployment is authorized.

## Navigation and configuration

- Add Terminal to the existing Toolbox grid and register `/toolbox/terminal` in `lib/screens/toolbox/toolbox_routes.dart`.
- Keep terminal session controls, SSH/SFTP selection, tab switching and terminal fullscreen in the terminal workspace.
- Add one Terminal Configuration section to `lib/screens/settings/settings_screen.dart`. It contains terminal behavior/display preferences, environment variables, Shell Profiles, SSH Hosts and SSH Keys. Configuration details use existing Settings child-route conventions, under `/settings/terminal`.
- Source Web Server sharing is a separate optional capability from the local terminal and SSH client. The prior recommendation excluded it from the initial functional scope; the user's follow-up explicitly confirmed configuration placement, without explicitly resolving sharing scope. Do not silently introduce a listening service. If sharing is included in the accepted scope, its configuration belongs in this same group and the service stays off until explicitly enabled.
- Keep GSMLG's existing global theme, navigation, account, device and Wi-Fi settings. Do not import upstream's `RootSettingList` as another Settings root or duplicate those groups.
- Use current GSMLG adaptive scaffolds and navigation selection. Configuration pages select Settings; the terminal workspace selects Toolbox. Keep mobile keyboard visibility behavior and desktop shortcuts, adapting their navigation dependencies.

## Package and dependency ownership

Copy terminal-owned packages into the existing monorepo layout, keeping source names and paths where practical:

- `app_lib/terminal_core`, `app_lib/terminal_hosts`, `app_lib/ssh`, `app_lib/security`, and `app_lib/utils` when required by the verified dependency closure.
- `app_bloc/terminal_tab`, `app_bloc/terminal_settings`, `app_bloc/shell_profile`, `app_bloc/ssh_host` and `app_bloc/ssh_key`.
- `app_widget/xterm`, `app_widget/terminal_plugin`, `app_widget/terminal_tabs`, `app_widget/starter_plugin`, `app_widget/file_manager_plugin` and the terminal-specific pieces of `app_widget/terminal_settings`.
- `app_plugin/pty`, `app_plugin/android_shell`, `app_plugin/ios_shell` and `third_party/flex_tabs`.

Register workspace packages with `any` dependencies and the root workspace list. Calculate the actual import closure before copying; include source tests, licenses and native build inputs. Do not copy unrelated source app scaffolding, theme, artwork, client-info or shared utility packages already provided compatibly by GSMLG.

`terminal_settings` currently exports a whole-app settings root that imports `web_session_bloc`; importing the entire package is therefore not evidence that the standalone terminal requires Web Server. Select reusable terminal components and record intentional exclusions in the synchronization manifest. Do not remove a needed feature or hide a dependency error to make analysis pass.

Use GSMLG-owned wrappers for application screens in `lib/screens/toolbox/terminal/` and `lib/screens/settings/terminal/`. Keep adaptations explicit: application package imports, destinations, Settings routes, shared service injection, and localization. Do not rewrite terminal algorithms merely to conform to local naming.

## Shared database, vault and localization

Extend the current `app_lib/database` package with the source SSH key, SSH host and Shell Profile tables, converters and necessary APIs. Preserve the public table/data contracts used by copied packages where compatible. Add a forward migration from GSMLG's current schema (18 at implementation; 17 during initial design); source schema version 4 must not replace the application schema or its migration history. New installations and upgrades must produce the same terminal tables without modifying existing feature data. Regenerate Drift outputs from local sources.

Use the existing `app_secure_storage` implementation. Add the SSH credential repository and its required dependencies without replacing the current vault implementation or platform compatibility logic. Inject stable, terminal-specific vault namespaces. Store secrets in Vault and opaque references in SQLite; retain first-use SSH host-key confirmation and reject changed fingerprints. New vault namespaces must not clear existing app credentials.

This migrates feature code, not another installed app's private user data. Access to Web Terminal's existing platform sandbox/keychain is not implied. Cross-app user-data import is outside this migration.

Merge terminal localization keys into `app_lib/locale` per supported locale, inspecting existing keys and placeholders for semantic conflicts. Do not overwrite existing ARB files or import a second `app_locale` package. Regenerate localizations with the repository command.

## Dependency injection and lifecycle

Register terminal repositories and BLoCs in `app_lib/provider/lib/src/main.dart`, the existing DI authority. Do not move DI into `main.dart` or create another MaterialApp. Initialize terminal resources lazily where compatible with profile/default loading.

The application owns live sessions. Navigating from Toolbox to Settings and back must not duplicate or silently terminate sessions. Closing a terminal tab disposes its terminal plugin and connection; final application teardown disposes all remaining resources. Persist restorable tab metadata, not a claim that processes or SSH connections survive app restart. Reopening restores configured sessions through their normal connection flow.

Preserve cancellation boundaries: closing an SSH execution channel must not close sibling channels on a shared transport; closing a PTY must reclaim its process and native resources. Check process-exit, startup failure, repeated open/close and partially initialized cleanup paths.

## Native platforms

Desktop uses the source PTY implementation; Android uses the source bundled shell/rootfs integration; iOS uses the source ios_system integration. Inventory tracked versus generated/downloaded binaries, checksums, licenses, framework slices, minimum platform versions and build scripts before registering plugins. Do not treat a locally present ignored framework as a reproducible build input.

Preserve platform capability checks. A browser cannot execute the desktop/mobile local shell; do not promise web support from the repository README alone. Report macOS, Linux, Windows, Android, iOS and browser validation separately and identify unavailable runtime environments.

## Updating from Web Terminal

Create `.agents/skills/sync-web-terminal/SKILL.md` with a companion synchronization script and a checked-in source manifest, following the skill-creation workflow at implementation time.

The manifest records source repository identity and full baseline SHA, copied path mappings, shared-package merge mappings, intentionally excluded files, local adaptations and source licenses. Use repository-relative destination paths. Allow a configurable source checkout, defaulting to the sibling `../web-terminal`; do not bake a developer-specific absolute path into operational scripts.

Synchronization behavior:

1. Validate repository identities, source commit availability and dirty files affecting the synchronization. Preserve unrelated work and report overlapping edits.
2. Default to a read-only comparison/report. Compare old source baseline, selected new source revision and local destination. Review the complete dependency closure, native assets, dependency constraints, tests and license changes.
3. Apply authorized updates with three-way comparison. Stop conflicting files for review; never recursively overwrite shared packages or silently resolve semantic conflicts. Merge database, vault, provider, route and locale additions explicitly.
4. Run the relevant verification below. Record native/runtime limits and unresolved failures. Re-running the same successful revision should produce no changes.
5. Advance the recorded baseline only after required checks pass. Keep a failed update's prior baseline intact so it remains reproducible. Require explicit user authorization for commit/push and any upstream code edits.

If a confirmed dependency problem requires Web Terminal support, use `upstream-issue-routing`, search existing issues and file/reuse an evidenced request. The user authorized relevant issues. For blockers, stop only the affected work and do not patch around the upstream problem locally. Continue independent integration work where safe; resume after the real fix is available and verified.

## Verification and acceptance

- Run required GitNexus impact analysis before editing existing symbols and report direct callers, affected processes and risk. Graph gaps in Dart/native bindings require source-level review and real tests; zero graph callers is not proof of zero impact.
- Add migration coverage for an existing GSMLG database and a fresh database; confirm existing records survive, terminal tables/defaults are valid, and reopen succeeds.
- Exercise credential storage/readback and missing-secret failure, SSH host-key first use/rejection/change, and host/key/profile persistence.
- Port relevant terminal, keyboard, tab, host and native lifecycle regressions. Verify that settings edits are consumed by the intended sessions according to source behavior.
- Add navigation coverage for Toolbox → Terminal and Settings → Terminal Configuration children, including leaving and returning to an active session.
- Run relevant analysis, formatting and workspace dependency checks. Inspect the integrated diff and generated outputs.
- Build and run available target platforms. Verify interactive input, resize, shell execution, SSH/SFTP, tab close and re-entry at the layer where they execute. Name any physical devices used; report build-only results separately from runtime evidence.
- Verify synchronization comparison on an unchanged revision, a source update, an overlapping local edit and failed verification without baseline advancement.

Completion means the accepted functional scope is integrated, the synchronization skill is usable, and all available required checks are recorded honestly. Missing physical devices or host platforms remain explicit verification limits, not successful platform claims.
