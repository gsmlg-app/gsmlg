# AGENTS.md

This file provides guidance to coding agents when working with code in this repository.

## Project Overview

**GSMLG** is a cross-platform developer toolbox app combining on-device AI chat (Google Gemma), cloud service management (Vultr, GitHub, CloudFlare DNS), and network utilities (WHOIS, IP geolocation, Bluetooth scanner). Built as a Flutter monorepo with ~50 packages, BLoC state management, and Dart workspace. Requires Dart SDK `>=3.8.0 <4.0.0`.

## Development Commands

```bash
# Setup
dart pub global activate melos && dart pub global activate mason_cli
melos bootstrap && mason get

# Full prepare (bootstrap + gen-l10n + build-runner)
melos run prepare

# Lint & format
melos run analyze          # --fatal-warnings across all packages
melos run format
melos run format-check     # CI validation (exits non-zero on diff)

# Tests
melos run test             # All tests (dart + flutter)
melos run test:dart        # Non-Flutter packages only
melos run test:flutter     # Flutter packages only
flutter test test/screens/splash_screen_test.dart   # Single file

# Code generation (per package)
dart run build_runner build --delete-conflicting-outputs

# Fix & validate
melos run fix              # dart fix --apply across all packages
melos run fix-dry-run      # Preview fixes without applying
melos run validate-dependencies

# Run app
flutter run -d macos       # or chrome, linux
```

**Note:** Melos configuration is inline in the root `pubspec.yaml` (no separate `melos.yaml`).

### Mason Code Generation

```bash
mason make screen --name ScreenName --folder subfolder
mason make widget --name WidgetName --type stateless --folder components
mason make simple_bloc -o app_bloc/feature_name --name=feature_name
mason make api_client -o app_api/app_api --package_name=app_api
mason make native_plugin --name plugin_name --description "Description" --package_prefix app -o app_plugin
```

See [BRICKS.md](./docs/BRICKS.md) for complete brick documentation.

## Architecture

### Directory Layout

```
lib/                        Main app (main.dart, app.dart, router.dart, screens/)
app_bloc/                   BLoC packages (one per feature domain)
app_lib/                    Core libraries (database, theme, locale, provider, logging, secure_storage, chat, isolate_orchestrator)
app_widget/                 UI components (adaptive, artwork, feedback, web_view, components, data_list, world_map)
app_api/                    API clients (route53, cloudflare_dns, github, vultr_api)
app_form/                   Form modules (camera_settings)
app_plugin/                 Native plugins (federated client_info)
monitor_models/             Shared models for device monitoring
monitor_agent/              Background agent for device monitoring
third_party/                Modified third-party packages
bricks/                     Mason templates
```

### Package Dependencies

Use `<package_name>: any` for workspace packages in pubspec.yaml. Never use path dependencies. New packages must be added to the root `pubspec.yaml` `workspace:` list and `dependencies:` section.

### App Initialization Flow

`lib/main.dart` initializes logging, SharedPreferences, AppDatabase, and SecureStorageVaultRepository, then assembles the widget tree: `MainProvider` → `MaterialApp` (localization + crash reporting) → `CrashReportingWidget` → `App`. This outer `MaterialApp` provides localization delegates; the inner one in `App` handles routing and theming.

`app_lib/provider/lib/src/main.dart` (`MainProvider`) is the **single source of truth** for all dependency injection. It registers:
- **Repositories** via `MultiRepositoryProvider`: SharedPreferences, AppDatabase, VaultRepository, GemmaRepository, ChatStorageRepository, ToolExecutor
- **BLoCs** via `MultiBlocProvider`: all app BLoCs in dependency order (DmThemeBloc, AuthBloc, WhoisBloc, WhoisHistoryBloc, BluetoothBloc, CameraBloc, ZoneBloc, RecordBloc, GitHubBloc, VultrBloc, AccountsBloc, ChatSettingsBloc, GemmaModelBloc, ChatBloc, MonitorBloc)

When adding a new BLoC, register it in `MainProvider`, not in `main.dart`.

`lib/app.dart` consumes `DmThemeBloc` and creates `MaterialApp.router` with GoRouter. Note the **nested MaterialApp** pattern: the outer one in `main.dart` handles localization/crash-reporting, the inner one in `app.dart` handles routing/theming.

### Routing

Routes are organized by feature domain. Each feature has a `*_routes.dart` file exporting a `GoRoute` function:
- `lib/router.dart` composes routes: `serviceRoutes()`, `toolboxRoutes()`, `chatRoutes()`, `settingsRoutes()`
- Top-level routes use absolute paths (`/home`), nested routes use relative paths (`domain`, `:zoneId`)
- All pages use `NoTransitionPage`

Screens define static routing constants:
```dart
class DomainScreen extends StatefulWidget {
  static const name = 'Domain';
  static const path = 'domain';       // relative for nested, '/domain' for top-level
}
```

### Navigation

`lib/destination.dart` (`Destinations` class) maps the 4 main navigation tabs: Home, Service, Toolbox, Settings. Screens use `AppAdaptiveScaffold` with:
```dart
selectedIndex: Destinations.indexOf(const Key(ServiceScreen.name), context),
destinations: Destinations.navs(context),
onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
```

### Screen Organization

```
lib/screens/
├── app/         Splash, error screens
├── home/        Home screen
├── service/     Infrastructure services
│   ├── domain/    DNS zone management
│   ├── github/    GitHub integration
│   └── vultr/     Vultr cloud servers
├── toolbox/     Utility tools
│   ├── camera/    Camera
│   ├── ip_geo/    IP geolocation
│   ├── whois/     WHOIS lookup
│   └── bluetooth/ Bluetooth scanner
├── chat/        On-device LLM chat
├── settings/    App settings
└── sign/        Authentication
```

### BLoC Pattern

Each feature BLoC lives in its own package under `app_bloc/`:
- `lib/src/bloc.dart` — Bloc class with event handlers
- `lib/src/event.dart` — Sealed event classes (`part of 'bloc.dart'`)
- `lib/src/state.dart` — Sealed state classes (`part of 'bloc.dart'`)
- Events/states extend `Equatable`, use `@immutable` and `sealed class`

### On-Device LLM (Chat)

`app_lib/chat` provides `GemmaRepository` (model management via flutter_gemma) and `ChatStorageRepository` (conversation persistence via AppDatabase). The chat feature BLoCs (`ChatSettingsBloc`, `GemmaModelBloc`, `ChatBloc`) live in `app_bloc/chat`. Desktop platforms (macOS/Linux/Windows) require `.litertlm` model format and a bundled Java gRPC server (`litertlm-server.jar`).

### Secure Storage

`app_secure_storage` provides `VaultRepository` (abstract) and `SecureStorageVaultRepository` (platform-native implementation). BLoCs that need API keys accept `VaultRepository` in their constructor (e.g., `GitHubBloc`, `VultrBloc`). Domain-specific credential helpers like `CredentialsService` wrap the vault.

### Localization

`app_lib/locale` provides `AppLocale` with delegates and supported locales. Access strings via `context.l10n.keyName`. Add new strings in ARB files and run `melos run gen-l10n`.

## Custom Skills (Claude Code)

Project-specific skills in `.claude/skills/`:
- `/project-bloc`, `/project-screen`, `/project-widget`, `/project-plugin`, `/project-locale`
- `/project-api`, `/project-form`, `/project-database`, `/project-secure-storage`, `/project-feedback`
- `/data-visualization`, `/template-mason-brick`

## Code Style

- flutter_lints rules from analysis_options.yaml
- Generated files (`*.g.dart`, `*.freezed.dart`) excluded from analysis
- BLoC pattern for state management, repository pattern for data layer
- Prefer const constructors
- Error handling: try/catch with `app_logging` package for structured logging
- Uses Nix/Devenv for reproducible environment (auto-loads via direnv)

## CI Workflows

- `ci.yml` — Format check, analyze, test, build Linux (skips for docs/config changes)
- `release.yml` — Manual workflow for platform release builds (android, ios, linux, macos)
- `release-agent.yml` — Manual workflow for monitor agent releases
- `deploy.yml` — Manual workflow for Play Store/App Store deployment via Fastlane

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **gsmlg** (26127 symbols, 59111 relationships, 300 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> If any GitNexus tool warns the index is stale, run `npx gitnexus analyze` in terminal first.

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `gitnexus_impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `gitnexus_detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `gitnexus_query({query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `gitnexus_context({name: "symbolName"})`.

## Never Do

- NEVER edit a function, class, or method without first running `gitnexus_impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `gitnexus_rename` which understands the call graph.
- NEVER commit changes without running `gitnexus_detect_changes()` to check affected scope.

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/gsmlg/context` | Codebase overview, check index freshness |
| `gitnexus://repo/gsmlg/clusters` | All functional areas |
| `gitnexus://repo/gsmlg/processes` | All execution flows |
| `gitnexus://repo/gsmlg/process/{name}` | Step-by-step execution trace |

## CLI

| Task | Read this skill file |
|------|---------------------|
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->
