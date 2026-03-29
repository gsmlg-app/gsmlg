# GSMLG

A cross-platform developer toolbox and services management app built with Flutter. Combines on-device AI chat (Google Gemma), cloud service management (Vultr, GitHub, CloudFlare DNS), and network utilities (WHOIS, IP geolocation, Bluetooth scanner) in a single privacy-first application.

## Features

- **On-Device AI Chat** - Run Google Gemma language models locally with conversation history and customizable system prompts
- **Cloud Service Management** - Manage Vultr instances, GitHub repositories, and CloudFlare DNS zones from one place
- **Network Tools** - WHOIS lookup with history, IP geolocation via local database, Bluetooth device scanning
- **Cross-Platform** - Runs on Android, iOS, macOS, Linux, Windows, and Web
- **Privacy-First** - LLM inference happens on-device; conversations never leave your machine

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK `>=3.8.0 <4.0.0`

### Setup

```bash
dart pub global activate melos && dart pub global activate mason_cli
melos bootstrap && mason get
melos run prepare
```

### Run

```bash
flutter run -d macos       # or chrome, linux, android, ios
```

## Monorepo Structure

This project is organized as a Dart workspace with ~50 packages managed by [Melos](https://melos.invertase.dev/):

| Directory | Purpose |
|-----------|---------|
| `lib/` | Main app entry, routing, and screens |
| `app_bloc/` | BLoC state management (one package per feature) |
| `app_lib/` | Core libraries: database, theme, locale, logging, secure storage, chat |
| `app_widget/` | UI components: adaptive scaffold, artwork, feedback, world map |
| `app_api/` | API clients: Route53, CloudFlare DNS, GitHub, Vultr |
| `app_form/` | Form modules (camera settings) |
| `app_plugin/` | Native plugins (federated client_info) |
| `third_party/` | Modified third-party packages |
| `bricks/` | Mason code generation templates |

## Common Commands

```bash
melos run analyze          # Lint all packages
melos run format           # Format all packages
melos run test             # Run all tests
melos run prepare          # Bootstrap + gen-l10n + build-runner
melos run brick-test       # Test Mason templates
```

## Documentation

- [Mason Bricks Guide](./docs/BRICKS.md) - Code generation templates
- [Brick Testing](./docs/BRICK_TESTING.md) - Testing Mason bricks
- [Form BLoC Guide](./docs/FORM_BLOC.md) - Form validation and submission
- [CLAUDE.md](./CLAUDE.md) - AI assistant development guidance
