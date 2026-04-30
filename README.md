# GSMLG

A cross-platform developer toolbox and services management app built with Flutter. Combines on-device AI chat (Google Gemma), cloud service management (Vultr, GitHub, CloudFlare DNS), and network utilities (WHOIS, IP geolocation, Bluetooth scanner) in a single privacy-first application.

## Features

- **On-Device AI Chat** - Run Google Gemma language models locally with conversation history and customizable system prompts
- **Cloud Service Management** - Manage Vultr instances, GitHub repositories, and CloudFlare DNS zones from one place
- **Network Tools** - WHOIS lookup with history, IP geolocation via local database, Bluetooth device scanning
- **Cross-Platform** - Runs on Android, iOS, macOS, Linux, Windows, and Web
- **Privacy-First** - LLM inference happens on-device; conversations never leave your machine

## Screens

### Home

The main landing screen with an animated GSMLG logo and quick access to all sections via the navigation bar.

### Chat

On-device AI chat powered by Google Gemma models. Includes conversation history, configurable system prompts, and model management. All inference runs locally — no data leaves the device.

- **Chat** - Send messages and receive responses from Gemma models
- **Chat History** - Browse and resume previous conversations
- **Chat Settings** - Configure default system prompts and generation parameters

### Services

Cloud infrastructure management from a single dashboard.

- **Domain (DNS)** - Manage CloudFlare DNS zones and records. Sync zones, add/edit/delete records, and browse zone details
- **GitHub** - Browse your GitHub repositories with pinned repos and search. View repository details and metadata
- **Vultr** - Monitor and manage Vultr cloud instances. View server status, specs, and configuration

### Toolbox

A collection of network and device utility tools.

- **WHOIS** - Look up domain and IP registration information with automatic search history tracking
- **IP Geolocation** - Locate IP addresses on a world map using a local offline database
- **Bluetooth Scanner** - Discover and inspect nearby Bluetooth devices (Android, iOS, macOS)
- **Camera** - Access device camera for photo and video capture, with a dedicated macOS implementation
- **Monitor** - Real-time system metrics dashboard for machines on the local network. Connects to monitor agents via WebSocket with mDNS auto-discovery, displaying CPU, memory, GPU, network, and disk metrics through radial gauges and sparkline charts

### Settings

App configuration and device information.

- **Account** - Authentication and credential management
- **Appearance** - Theme selection (light/dark/system) and accent color customization
- **Model Management** - Download, install, and switch between Gemma language models
- **Device Info** - Hardware and software details for the current device
- **Wi-Fi Info** - Network connection details and status

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
| `app_lib/` | Core libraries: database, theme, locale, logging, secure storage, chat, isolate orchestration |
| `app_widget/` | UI components: adaptive scaffold, artwork, feedback, world map |
| `app_api/` | API clients: Route53, CloudFlare DNS, GitHub, Vultr |
| `app_form/` | Form modules (camera settings) |
| `app_plugin/` | Native plugins (federated client_info) |
| `monitor_models/` | Shared models for device monitoring |
| `monitor_agent/` | Background agent for device monitoring |
| `third_party/` | Modified third-party packages |
| `bricks/` | Mason code generation templates |

## Common Commands

```bash
melos run analyze          # Lint all packages
melos run format           # Format all packages
melos run test             # Run all tests
melos run prepare          # Bootstrap + gen-l10n + build-runner
```

## Documentation

- [Documentation Index](./docs/INDEX.md) - Full index of all docs
- [Mason Bricks Guide](./docs/BRICKS.md) - Code generation templates
- [Brick Testing](./docs/BRICK_TESTING.md) - Testing Mason bricks
- [Testing Guide](./docs/TESTING.md) - Running tests across the monorepo
- [Form BLoC Guide](./docs/FORM_BLOC.md) - Form validation and submission
- [Isolate Orchestrator](./docs/ISOLATE_ORCHESTRATOR.md) - Managed Dart isolate pools for long-running background workers
- [Error Handling](./docs/USAGE.md) - Error handling system setup and usage
- [Logging & Error Architecture](./docs/DOCUMENTATION.md) - Logging and error handler internals
- [Deployment Setup](./docs/DEPLOYMENT_SETUP.md) - Play Store and App Store deployment configuration
- [Monitor PRD](./docs/MONITOR_PRD.md) - Monitor module requirements
- [Monitor Design](./docs/MONITOR_DESIGN.md) - Monitor architecture and protocol
- [Monitor Implementation](./docs/MONITOR_IMPLEMENTATION.md) - Monitor build guide
- [CLAUDE.md](./CLAUDE.md) - AI assistant development guidance
