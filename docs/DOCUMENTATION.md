# Error Handling & Logging System

## Architecture

The error handling and logging system spans three packages:

```
app_lib/logging/           # Core: AppLogger, ErrorReportingService, CrashReportingWidget, ErrorDisplay
app_bloc/error_handler/    # BLoC: ErrorBloc for error lifecycle management
app_widget/feedback/       # UI: re-exports duskmoon_feedback (toasts, dialogs, snackbars)
```

## Core Logging (`app_lib/logging`)

### AppLogger

Singleton logger wrapping `package:logging`. Exposes a broadcast `logStream` of `LogRecord` objects.

```dart
final logger = AppLogger();
logger.initialize(level: LogLevel.debug);

logger.v('verbose');  logger.d('debug');  logger.i('info');
logger.w('warning');  logger.e('error');  logger.f('fatal');
```

In `main.dart`, the log stream is subscribed to and written to `<applicationSupportDirectory>/gsmlg/app.log`.

### LogLevel

Enhanced enum with 6 levels: `verbose(0)`, `debug(1)`, `info(2)`, `warning(3)`, `error(4)`, `fatal(5)`. Supports comparison operators.

### LogRecord

Immutable data class with: `level`, `message`, `error`, `stackTrace`, `loggerName`, `time`, `zone`.

### ErrorReportingService

Singleton that stores error records in SharedPreferences (capped at 100). Provides:

- `reportError(...)` / `reportException(...)` / `reportFlutterError(...)` -- log and persist errors
- `getRecentErrors()` -- retrieve stored error history
- `clearErrorLogs()` -- clear stored errors
- `setupGlobalErrorHandler()` -- install `FlutterError.onError` and `PlatformDispatcher.instance.onError`

### CrashReportingWidget

StatefulWidget that wraps the app and installs global error handlers via `ErrorReportingService`. Used in `main.dart`:

```dart
MainProvider(
  child: MaterialApp(
    home: CrashReportingWidget(child: const App()),
  ),
)
```

Optional parameters: `showErrorScreen` (default true), `errorScreenBuilder`.

Also provides `ErrorBoundary` (widget-level error boundary) and `ErrorScreen` (full-screen error UI with retry/report actions).

### ErrorDisplay

Static utility for showing severity-based error UI:

| Severity | UI |
|----------|------|
| `low` | SnackBar (2s) |
| `medium` | SnackBar (4s) |
| `high` | Non-dismissible AlertDialog with retry |
| `critical` | AlertDialog with restart prompt |

```dart
ErrorDisplay.showError(context, 'Something failed', severity: ErrorSeverity.high);
```

### ApiLoggingInterceptor

Structured HTTP logging utility. Not a Dio interceptor -- provides standalone methods:

- `logRequest(...)` / `logResponse(...)` / `logError(...)` -- request lifecycle logging
- `logPerformance(...)` -- duration-based severity (>5s = error, >1s = warning)
- `logAuth(...)` / `logConnectivity(...)` / `logRateLimit(...)` / `logValidation(...)` -- specialized logging

Truncates bodies to 1000 chars.

## Error State Management (`app_bloc/error_handler`)

### ErrorBloc

Manages error lifecycle with these events:

| Event | Effect |
|-------|--------|
| `ErrorReported` | Creates `AppError`, adds to `activeErrors` |
| `ErrorDismissed` | Removes error by ID from active list |
| `ErrorsCleared` | Clears all active errors |
| `ErrorRecovered` | Moves error to `resolvedErrors` |

Convenience methods on the bloc:

```dart
errorBloc.reportError(error, severity: ErrorSeverity.high);
errorBloc.reportNetworkError(error);       // severity: medium
errorBloc.reportValidationError('msg');     // severity: low
errorBloc.reportUnexpectedError(error);     // severity: high
```

### ErrorState

Fields: `activeErrors` (List\<AppError\>), `resolvedErrors` (List\<AppError\>), `isLoading`, `lastErrorMessage`.

Getters: `hasErrors`, `hasCriticalErrors`.

### AppError

Immutable error record with: `id`, `error`, `stackTrace`, `context`, `severity`, `timestamp`, `isResolved`, `userMessage`. The `displayMessage` getter provides user-friendly text.

**Note:** `ErrorBloc` is defined in `app_bloc/error_handler` but is not currently registered in `MainProvider`. To use it, add it to the `MultiBlocProvider` in `app_lib/provider/lib/src/main.dart`.

## Feedback Widgets (`app_widget/feedback`)

Re-exports `package:duskmoon_feedback` plus backward-compatible aliases:

```dart
showAppDialog<T>(...)      // → showDmDialog<T>(...)
showSuccessToast(...)      // → showDmSuccessToast(...)
showErrorToast(...)        // → showDmErrorToast(...)
showSnackbar(...)          // → showDmSnackbar(...)
showUndoSnackbar(...)      // → showDmUndoSnackbar(...)
```
