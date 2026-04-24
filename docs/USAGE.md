# Error Handling System Usage

## Setup

### 1. Initialize logging in main.dart

```dart
import 'package:app_logging/app_logging.dart';

final logger = AppLogger();
logger.initialize(level: LogLevel.debug);
```

### 2. Wrap your app with crash reporting

```dart
runApp(
  MainProvider(
    child: MaterialApp(
      home: CrashReportingWidget(child: const App()),
    ),
  ),
);
```

`CrashReportingWidget` installs global error handlers for `FlutterError.onError` and `PlatformDispatcher.instance.onError`, routing errors through `ErrorReportingService`.

## Logging

```dart
final logger = AppLogger();

logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message', error, stackTrace);
logger.f('Fatal error', error, stackTrace);
```

The log stream is written to `<applicationSupportDirectory>/gsmlg/app.log`.

## API Logging

```dart
final apiLogger = ApiLoggingInterceptor();

apiLogger.logRequest(method: 'GET', url: 'https://api.example.com/users');

apiLogger.logResponse(
  method: 'GET',
  url: 'https://api.example.com/users',
  statusCode: 200,
  responseTimeMs: 150,
);

apiLogger.logError(
  method: 'POST',
  url: 'https://api.example.com/data',
  error: e,
  stackTrace: stack,
);
```

## Error Display

Show errors to users with severity-appropriate UI:

```dart
// SnackBar for low/medium severity
ErrorDisplay.showError(context, 'Network issue', severity: ErrorSeverity.medium);

// Dialog for high severity
ErrorDisplay.showError(
  context,
  'Failed to save',
  severity: ErrorSeverity.high,
  onRetry: () => retryOperation(),
);

// Critical error dialog
ErrorDisplay.showError(context, 'Unrecoverable error', severity: ErrorSeverity.critical);
```

## Error Reporting Service

```dart
final service = ErrorReportingService();

// Report errors (persisted to SharedPreferences)
service.reportError(error: e, context: 'Loading user data');
service.reportFlutterError(details: errorDetails);

// Retrieve stored errors
final errors = await service.getRecentErrors();

// Clear error history
await service.clearErrorLogs();
```

## Feedback Widgets

For toasts and dialogs (via `app_feedback` package):

```dart
import 'package:app_feedback/app_feedback.dart';

showSuccessToast(context, message: 'Saved successfully');
showErrorToast(context, message: 'Operation failed');
showAppDialog<bool>(
  context: context,
  title: 'Confirm',
  message: 'Are you sure?',
  actions: [
    AppDialogAction(label: 'Cancel', value: false),
    AppDialogAction(label: 'OK', value: true),
  ],
);
```
