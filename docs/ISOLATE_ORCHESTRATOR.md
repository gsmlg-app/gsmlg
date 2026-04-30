# Isolate Orchestrator

`app_lib/isolate_orchestrator` is a pure Dart workspace package for managing long-running isolate pools. It provides a central hub, worker lifecycle management, health checks, restart policy support, request-response correlation, routing strategies, and cross-isolate logging.

## Package

Use the workspace dependency from any package in this repository:

```yaml
dependencies:
  isolate_orchestrator: any
```

Import the public API:

```dart
import 'package:isolate_orchestrator/isolate_orchestrator.dart';
```

Test helpers are exposed separately:

```dart
import 'package:isolate_orchestrator/testing.dart';
```

## When to Use

Use this package for CPU-heavy or long-running work that needs to stay off the UI isolate while still being managed as a reusable pool. Typical use cases include local model preparation, batch processing, parsing, data indexing, and network utility workloads that benefit from concurrent workers.

## Main Concepts

- `IsolateHub` owns worker registration, lifecycle, and health monitoring.
- `WorkerPool<T>` spawns and routes requests to typed workers.
- `Worker<T>` implements the user-defined task handler.
- Routers support round-robin, consistent-hash, and least-connections dispatch.
- Request management handles correlation, retries, cancellation, and timeout cleanup.

See [the package README](../app_lib/isolate_orchestrator/README.md) for usage examples and [the design document](../app_lib/isolate_orchestrator/design.md) for architecture details.
