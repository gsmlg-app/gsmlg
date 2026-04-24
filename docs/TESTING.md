# Testing Guide

## Test Commands

| Command | Description |
|---------|-------------|
| `melos run test` | Run all tests (`test:dart` then `test:flutter`) |
| `melos run test:dart` | Dart-only packages with a `test/` directory |
| `melos run test:flutter` | Flutter packages with a `test/` directory |
| `flutter test test/screens/splash_screen_test.dart` | Single test file |

Both `test:dart` and `test:flutter` use `--fail-fast` and `--order-dependents`. Packages without a `test/` directory are automatically skipped.

## Packages with Tests

### Main App (`test/`)

Screen widget tests: `splash_screen_test.dart`, `error_screen_test.dart`, `home_screen_test.dart`, `settings_screen_test.dart`, `app_settings_screen_test.dart`.

### BLoC Packages (`app_bloc/`)

`auth`, `bluetooth`, `camera`, `domain`, `github`, `theme`, `whois`, `whois_history` each have a single BLoC test file using `bloc_test`.

Without tests: `accounts`, `chat`, `error_handler`, `monitor`, `vultr`.

### Library Packages (`app_lib/`)

`database`, `ip_db`, `locale`, `provider`, `secure_storage`, `theme` each have tests.

Without tests: `logging`, `chat`.

### Widget Packages (`app_widget/`)

`adaptive`, `artwork`, `components`, `feedback`, `web_view` each have tests.

Without tests: `data_list`, `world_map`.

### Other

- `app_form/camera_settings` -- form test
- `app_plugin/client_info/client_info` -- plugin test
- `app_api/vultr_api` -- ~440 auto-generated OpenAPI test files
- `app_api/cloudflare_dns`, `app_api/github`, `app_api/route53` -- placeholder tests
- `monitor_models` -- serialization round-trip tests

### Without Tests

`monitor_agent`, `third_party/gsmlg_whois`, all `client_info_*` platform packages.

## CI Integration

The `ci.yml` workflow runs four parallel jobs on push/PR to `main`:

1. **Format Check** -- `melos run format-check`
2. **Analyze** -- `melos run analyze` (both dart and flutter)
3. **Test** -- `melos run test`
4. **Build Linux** -- `flutter build linux --release`

All jobs run `melos run prepare` first (bootstrap + gen-l10n + build-runner). CI skips runs for changes to `*.md`, `docs/`, `.claude/`, `.vscode/`, `.idea/`.

## Writing Tests

### Widget Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MyWidget renders correctly', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MyWidget()));
    expect(find.text('Hello'), findsOneWidget);
  });
}
```

### BLoC Test

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

void main() {
  blocTest<MyBloc, MyState>(
    'emits [Loading, Loaded] on MyEvent',
    build: () => MyBloc(),
    act: (bloc) => bloc.add(const MyEvent()),
    expect: () => [isA<MyLoading>(), isA<MyLoaded>()],
  );
}
```
