# Monitor Module — Product Requirements Document

## 1. Overview

The Monitor module is a new tool within the GSMLG app's Toolbox section. It provides real-time visibility into system metrics (CPU, memory, GPU, network I/O, disk I/O) of nearby computers on the local network.

The system consists of two components:

- **Monitor Agent** — A Dart CLI daemon that runs on target machines, collects system metrics, and pushes them to connected clients over WebSocket.
- **Monitor Client** — A Flutter screen within the GSMLG app that discovers agents via mDNS, connects over WebSocket, and renders live dashboards.

## 2. Goals

- Monitor any computer on the local network running the agent — Linux, macOS, and Windows.
- Zero-configuration discovery of agents via mDNS/DNS-SD, with fallback to manual IP entry.
- Real-time metrics pushed from agent to client at 2–5 second intervals over WebSocket.
- Clean integration with existing monorepo architecture: BLoC state management, package decomposition, GoRouter navigation, MainProvider DI.

## 3. Non-Goals (v1)

- Historical metrics storage or time-series database.
- Remote management or command execution on monitored machines.
- Alerting or threshold-based notifications.
- Monitoring of containers, VMs, or cloud instances.
- Agent auto-update mechanism (version mismatch is warned, not auto-resolved).

## 4. User Stories

### US-1: Auto-discover agents

As a user, I open the Monitor screen and see a list of all machines on my network running the monitor agent, without any manual configuration.

### US-2: Manual host entry

As a user, I can add a host by IP address and port when mDNS discovery is unavailable (e.g., across subnets).

### US-3: View live dashboard

As a user, I tap a discovered host and see a real-time dashboard with CPU usage, memory usage, GPU usage, network throughput, and disk throughput — all updating every few seconds.

### US-4: Multi-host overview

As a user, I can see a summary list of all connected hosts with key metrics (CPU %, memory %) at a glance, then drill into any host for the full dashboard.

### US-5: Run agent on any machine

As a user, I install the Dart runtime on a target machine, run `dart run monitor_agent`, and it starts broadcasting metrics with zero configuration. Alternatively, I download a pre-compiled binary from GitHub Releases and run it directly without needing the Dart SDK.

### US-6: Reconnection

### US-7: Secure connection (TOFU)

As a user, when I first connect to an agent, the client shows me the agent's certificate fingerprint. I confirm it once, and all subsequent connections to that agent are encrypted and verified automatically. If the certificate changes unexpectedly, the client warns me.

### US-8: Agent version warning

As a user, if a connected agent is running an older version than my app expects, I see a warning badge on the host tile so I know to update the agent.

As a user, if the agent or network drops, the client automatically reconnects when the agent becomes available again.

## 5. Metrics Specification

### 5.1 CPU

| Field | Type | Description |
|-------|------|-------------|
| `usagePercent` | `double` | Aggregate CPU usage 0–100 |
| `perCore` | `List<double>` | Per-core usage percentages |
| `loadAvg` | `List<double>` | 1m, 5m, 15m load averages (Linux/macOS only; empty on Windows) |

### 5.2 Memory

| Field | Type | Description |
|-------|------|-------------|
| `usedBytes` | `int` | Physical memory in use |
| `totalBytes` | `int` | Total physical memory |
| `swapUsedBytes` | `int` | Swap in use |
| `swapTotalBytes` | `int` | Total swap |

### 5.3 GPU

| Field | Type | Description |
|-------|------|-------------|
| `index` | `int` | GPU device index |
| `name` | `String` | GPU model name |
| `usagePercent` | `double` | GPU utilization 0–100 |
| `memoryUsedBytes` | `int` | GPU memory in use |
| `memoryTotalBytes` | `int` | Total GPU memory |
| `temperatureCelsius` | `double?` | GPU temperature (nullable if unavailable) |

Note: GPU metrics may be empty if no supported GPU is detected. NVIDIA GPUs use `nvidia-smi` on Linux/Windows. Apple Silicon GPU utilization is collected via IOKit (`IOAccelerator` service) and Metal performance counters — this is a best-effort approach that may break across macOS versions. Intel/AMD iGPU on Linux/Windows have limited or no metric availability.

### 5.4 Network I/O

| Field | Type | Description |
|-------|------|-------------|
| `interface` | `String` | Network interface name |
| `txBytesPerSec` | `int` | Transmit rate |
| `rxBytesPerSec` | `int` | Receive rate |

Rates are computed as deltas between samples. Loopback (`lo`) is excluded by default.

### 5.5 Disk I/O

| Field | Type | Description |
|-------|------|-------------|
| `device` | `String` | Block device name |
| `readBytesPerSec` | `int` | Read throughput |
| `writeBytesPerSec` | `int` | Write throughput |
| `usedBytes` | `int` | Disk space used |
| `totalBytes` | `int` | Disk capacity |

## 6. Agent Specification

### 6.1 Execution

```bash
# Option A: From source (requires Dart SDK)
dart run monitor_agent

# Option B: Pre-compiled binary (no Dart SDK needed)
./gsmlg-monitor-agent              # Linux/macOS
gsmlg-monitor-agent.exe            # Windows

# Custom options (both methods)
dart run monitor_agent --port 9800 --interval 5
./gsmlg-monitor-agent --port 9800 --interval 5
```

### 6.1.1 Binary Distribution

Pre-compiled binaries are published as GitHub Release assets via `dart compile exe`. Target triples:

- `gsmlg-monitor-agent-linux-x64`
- `gsmlg-monitor-agent-linux-arm64`
- `gsmlg-monitor-agent-macos-x64`
- `gsmlg-monitor-agent-macos-arm64`
- `gsmlg-monitor-agent-windows-x64.exe`

A GitHub Actions workflow compiles and uploads binaries on each tagged release.

### 6.2 CLI Arguments

| Flag | Default | Description |
|------|---------|-------------|
| `--port` | `9723` | WebSocket server listen port |
| `--interval` | `3` | Metrics push interval in seconds (2–10) |
| `--no-mdns` | `false` | Disable mDNS service registration |
| `--bind` | `0.0.0.0` | Bind address |

### 6.3 mDNS Service Registration

- Service type: `_gsmlg-monitor._tcp`
- TXT records: `version=<agent_version>`, `hostname=<machine_hostname>`
- Registered on startup, deregistered on shutdown (SIGINT/SIGTERM)

### 6.4 TLS & Authentication (mTLS with TOFU)

All agent-client communication is encrypted via TLS. Authentication uses a Trust-On-First-Use (TOFU) model — no pre-shared secrets or central CA required.

**Agent-side (certificate generation):**

- On first launch, the agent generates a self-signed X.509 certificate + private key.
- Stored in `~/.gsmlg-monitor/cert.pem` and `~/.gsmlg-monitor/key.pem`.
- Certificate CN is set to the machine hostname; SANs include all local IPs.
- Certificate fingerprint (SHA-256) is printed to stdout on startup for out-of-band verification.
- Certificate is reused on subsequent launches. Regenerated with `--regen-cert` flag.

**Client-side (TOFU pinning):**

1. First connection to a new host: client receives the agent's certificate.
2. Client displays the certificate fingerprint and prompts the user to confirm ("Trust this agent?").
3. On confirmation, the fingerprint is stored in `AppDatabase` (table `monitor_trusted_certs`).
4. Subsequent connections: client verifies the agent's certificate fingerprint matches the pinned value.
5. If the fingerprint changes (cert regenerated, MITM), client shows a security warning and blocks connection until the user explicitly re-trusts.

**Protocol change:**

- Agent serves WSS (WebSocket Secure) instead of plain WS.
- Connection URL: `wss://<host>:<port>/ws`
- The `dart:io` `SecurityContext` is configured to accept the self-signed cert after TOFU verification.

### 6.5 WebSocket Protocol

Connection lifecycle:

1. Client connects to `wss://<host>:<port>/ws` (TLS handshake with TOFU cert verification)
2. Agent sends `host_info` message (once)
3. Agent pushes `metrics` message at configured interval
4. Client may send `ping`; agent responds with `pong`
5. On disconnect, agent cleans up client subscription

Message envelope:

```
{
  "type": "host_info" | "metrics" | "ping" | "pong",
  "payload": { ... }
}
```

See [MONITOR_DESIGN.md](./MONITOR_DESIGN.md) §3 for full message schemas.

### 6.6 Platform Collection Matrix

| Metric | Linux | macOS | Windows |
|--------|-------|-------|---------|
| CPU | `/proc/stat` | `top -l 1 -n 0` | `wmic cpu get LoadPercentage` |
| Per-core CPU | `/proc/stat` per-line | `top -l 1 -n 0` | `wmic cpu get LoadPercentage` (per-socket) |
| Load avg | `/proc/loadavg` | `sysctl vm.loadavg` | N/A |
| Memory | `/proc/meminfo` | `vm_stat` + `sysctl hw.memsize` | `wmic os get FreePhysicalMemory,TotalVisibleMemorySize` |
| Swap | `/proc/meminfo` | `sysctl vm.swapusage` | `wmic pagefile get AllocatedBaseSize,CurrentUsage` |
| GPU util | `nvidia-smi --query-gpu` | IOKit `IOAccelerator` + Metal perf counters | `nvidia-smi --query-gpu` |
| Network IO | `/proc/net/dev` | `netstat -ibnd` | `Get-NetAdapterStatistics` (PowerShell) |
| Disk IO | `/proc/diskstats` | `iostat -d -c 2` | `Get-Counter '\PhysicalDisk(*)\Disk Read Bytes/sec'` (PowerShell) |
| Disk usage | `statvfs` / `df` | `df` | `wmic logicaldisk get Size,FreeSpace` |

All shell commands are executed via `Process.run` in a Dart isolate to avoid blocking the WebSocket server event loop.

## 7. Client Specification

### 7.1 Discovery Flow

1. On screen open, `MonitorBloc` emits `DiscoverHosts` event.
2. `MonitorRepository` starts mDNS browse for `_gsmlg-monitor._tcp`.
3. Discovered services appear in host list with status `discovered`.
4. User taps host → `ConnectHost` event → WS connection opens → status transitions to `connected`.
5. User can also tap "Add Host" → enters IP + port → `AddManualHost` event.

### 7.2 Dashboard Layout

**Host list (left panel / top on mobile):**
- Each host tile: hostname, OS icon, connection status indicator, CPU % and memory % summary
- Discovered hosts show a network icon badge; manual hosts show a pin icon
- Pull-to-refresh triggers re-scan

**Metrics dashboard (right panel / detail view on mobile):**
- CPU section: radial gauge (aggregate %) + per-core bar chart + load average text
- Memory section: radial gauge (used/total %) + swap indicator
- GPU section: per-GPU card with utilization gauge + memory bar + temperature
- Network section: per-interface sparkline (tx/rx over last 60 samples)
- Disk section: per-device sparkline (read/write) + capacity bar

### 7.3 Reconnection Behavior

- On WS disconnect, status transitions to `disconnected`.
- Client retries with exponential backoff: 1s, 2s, 4s, 8s, 16s, max 30s.
- On reconnect, agent re-sends `host_info` and resumes `metrics` stream.
- After 5 minutes of failed reconnection, host is marked `error`.

## 8. Milestones

### M1 — Core Agent + Basic Client

**Agent:**
- `monitor_models` package with all data models
- `monitor_agent` package with CPU and memory collectors (Linux only)
- Plain WebSocket server with `host_info` + `metrics` push (no TLS yet — development convenience)
- CLI entry point with `--port` and `--interval` flags

**Client:**
- `app_bloc/monitor` with `MonitorBloc` (connect/disconnect, receive metrics)
- Basic `MonitorScreen` under toolbox with manual host entry
- Text-based metrics display (no gauges yet)
- Route registration in `toolbox_routes.dart`
- BLoC registration in `MainProvider`

**Exit criteria:** Can run agent on a Linux machine, connect from GSMLG app by entering IP, and see live CPU + memory text values updating.

### M2 — Full Collectors + Visual Dashboard

**Agent:**
- All 5 metric collectors for Linux
- macOS collectors for CPU, memory, network, disk
- macOS GPU collector via IOKit `IOAccelerator` + Metal performance counters (best-effort, may return partial data)
- Windows collectors for CPU, memory, network, disk
- GPU collector (nvidia-smi) for Linux and Windows

**Client:**
- Radial gauge widgets for CPU, memory, GPU
- Sparkline chart widgets for network and disk IO
- Ring buffer (last 60 samples) for chart history
- Per-core CPU breakdown view
- Responsive layout: side-by-side on desktop, stacked on mobile

**Exit criteria:** Full dashboard rendering with all 5 metric types, collectors working on all 3 platforms (macOS GPU best-effort).

### M3 — mDNS Discovery + mTLS TOFU

**Agent:**
- mDNS service registration (`_gsmlg-monitor._tcp`)
- Graceful deregistration on shutdown
- Self-signed certificate generation on first launch (`~/.gsmlg-monitor/cert.pem`, `key.pem`)
- WSS (TLS) server replacing plain WS
- `--regen-cert` flag for certificate regeneration
- Certificate fingerprint printed on startup

**Client:**
- mDNS browse integration in `MonitorRepository`
- Auto-populated host list from discovery
- Visual distinction between discovered and manual hosts
- Pull-to-refresh discovery scan
- TOFU certificate pinning flow: fingerprint display → user confirmation → persist to `monitor_trusted_certs` table
- Certificate mismatch warning with re-trust option
- All connections upgraded to WSS

**Exit criteria:** Agents auto-discovered on same network. All connections encrypted. First-connect shows fingerprint confirmation dialog. Cert mismatch blocks connection with security warning.

### M4 — Polish, Persistence & Distribution

**Agent:**
- `--no-mdns` and `--bind` flags
- Graceful multi-client handling
- Structured logging
- `dart compile exe` build targets for 5 platform/arch combos
- GitHub Actions release workflow for binary distribution

**Client:**
- Exponential backoff reconnection
- Host persistence in `AppDatabase` (manual hosts + pinned certs survive app restart)
- Configurable push interval per host
- GPU temperature display with color coding
- Agent version comparison: warning badge on host tile when agent version < expected minimum
- Connection status animations
- Empty state and error state screens
- Localization strings in ARB files

**Exit criteria:** Production-quality experience — hosts persist, reconnection is seamless, binaries downloadable from GitHub Releases, version mismatch warned, all edge cases handled.

## 9. Dependencies

### Agent (Dart CLI)

| Package | Purpose |
|---------|---------|
| `shelf` + `shelf_web_socket` | WebSocket server |
| `multicast_dns` | mDNS service registration |
| `args` | CLI argument parsing |
| `monitor_models` | Shared data models (workspace dependency) |
| `pointycastle` | Self-signed certificate generation |

### Client (Flutter)

| Package | Purpose |
|---------|---------|
| `web_socket_channel` | WebSocket client |
| `multicast_dns` | mDNS service browsing |
| `data_visualization` | Gauges, sparklines, charts (own package) |
| `flutter_bloc` | State management (existing) |
| `monitor_models` | Shared data models (workspace dependency) |

### Agent (macOS GPU — native FFI)

The macOS IOKit GPU collector requires FFI bindings to `IOKit.framework`. This can be implemented via `dart:ffi` calling `IOServiceGetMatchingServices` and `IORegistryEntryCreateCFProperties` to read `IOAccelerator` performance statistics. This is inherently fragile and version-dependent — the collector must degrade gracefully to empty GPU data if the IOKit API changes.

## 10. Resolved Design Decisions

| # | Question | Decision | Impact |
|---|----------|----------|--------|
| 1 | Agent distribution | Both: `dart run` for developers, pre-compiled binaries via GitHub Releases for convenience | M4: add `dart compile exe` + release workflow |
| 2 | Authentication | mTLS with TOFU — agent generates self-signed cert on first run, client pins fingerprint on first connect | M3: TLS server, cert generation, TOFU pinning UI, `monitor_trusted_certs` table |
| 3 | Apple Silicon GPU | Use IOKit `IOAccelerator` + Metal perf counters for best-effort GPU utilization on macOS | M2: FFI-based macOS GPU collector, must degrade gracefully |
| 4 | Agent auto-update | Show warning badge on host tile when agent version < client's expected minimum | M4: version comparison logic in BLoC, badge widget |
