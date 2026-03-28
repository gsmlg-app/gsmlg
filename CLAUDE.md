# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter monorepo with modular architecture, BLoC state management, and comprehensive tooling. Organized as a Dart workspace with ~50 packages. Requires Dart SDK `>=3.8.0 <4.0.0`.

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

# Brick testing
melos run brick-test       # Tests Mason templates

# Run app
flutter run -d macos       # or chrome, linux
```

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
app_lib/                    Core libraries (database, theme, locale, provider, logging, secure_storage, chat)
app_widget/                 UI components (adaptive, artwork, feedback, web_view, components, data_list, world_map)
app_api/                    API clients (route53, cloudflare_dns, github, vultr_api)
app_form/                   Form modules (camera_settings)
app_plugin/                 Native plugins (federated client_info)
third_party/                Modified third-party packages
bricks/                     Mason templates
```

### Package Dependencies

Use `<package_name>: any` for workspace packages in pubspec.yaml. Never use path dependencies. New packages must be added to the root `pubspec.yaml` `workspace:` list and `dependencies:` section.

### App Initialization Flow

`lib/main.dart` initializes logging, SharedPreferences, AppDatabase, and SecureStorageVaultRepository, then passes them to `MainProvider`.

`app_lib/provider/lib/src/main.dart` (`MainProvider`) is the **single source of truth** for all dependency injection. It registers:
- **Repositories** via `MultiRepositoryProvider`: SharedPreferences, AppDatabase, VaultRepository, GemmaRepository, ChatStorageRepository
- **BLoCs** via `MultiBlocProvider`: all app BLoCs in dependency order (ThemeBloc, AuthBloc, WhoisBloc, WhoisHistoryBloc, BluetoothBloc, CameraBloc, ZoneBloc, RecordBloc, GitHubBloc, VultrBloc, AccountsBloc, ChatSettingsBloc, GemmaModelBloc, ChatBloc)

When adding a new BLoC, register it in `MainProvider`, not in `main.dart`.

`lib/app.dart` consumes `ThemeBloc` and creates `MaterialApp.router` with GoRouter.

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

- `ci.yml` — Format check, analyze, test, build (skips for docs/config changes)
- `brick-test.yml` — Tests Mason bricks (only on brick file changes)
- `release.yml` — Manual workflow for platform release builds (android, ios, linux, macos)
- `deploy.yml` — Manual workflow for Play Store/App Store deployment via Fastlane
