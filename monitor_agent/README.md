# Monitor Agent

System metrics agent daemon for GSMLG Monitor. Collects CPU, memory, GPU, network, and disk metrics and streams them over WebSocket to connected clients.

## Features

- Real-time system metrics collection (CPU, memory, GPU, network, disk)
- WebSocket server with TLS support (self-signed certificates)
- mDNS service registration for automatic discovery
- Platform-specific collectors for Linux, macOS, and Windows

## Build

Dart `compile exe` produces AOT-compiled native binaries with no runtime dependency. Cross-compilation is not supported — build on the target OS.

```bash
# macOS (build on macOS)
dart compile exe bin/monitor_agent.dart -o monitor_agent-macos

# Linux (build on Linux)
dart compile exe bin/monitor_agent.dart -o monitor_agent-linux
```

For development, run directly without compiling:

```bash
dart run bin/monitor_agent.dart
```

## Usage

```bash
./monitor_agent --port 9723 --interval 3
```

### CLI Options

| Flag | Default | Description |
|------|---------|-------------|
| `--port` | `9723` | WebSocket server port |
| `--interval` | `3` | Metrics push interval (seconds) |
| `--bind` | `0.0.0.0` | Bind address |
| `--no-mdns` | `false` | Disable mDNS registration |
| `--no-tls` | `false` | Disable TLS (plain WebSocket) |
| `--regen-cert` | `false` | Regenerate TLS certificate |
| `-h`, `--help` | | Show usage |
