# App Utils

A Flutter utility package providing color manipulation and platform detection helpers.

## Features

- **Color Utilities**: Material color generation, brightness estimation, shade calculation, darken/lighten operations
- **Platform Detection**: Extended platform checks for desktop, mobile, web, and AIM (Android/iOS/macOS)
- **Color Shades**: Enum-based color shade system compatible with Material Design

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  app_utils:
    path: ../app_lib/utils
```

## Usage

### Color Utilities

```dart
import 'package:app_utils/app_utils.dart';

// Convert any color to MaterialColor
final materialColor = GColorUtils.getMaterialColor(Colors.blue);

// Estimate brightness for contrast calculations
final brightness = GColorUtils.estimateBrightnessForColor(color);
// Returns Brightness.light or Brightness.dark

// Get dark shades of a color
final darkShades = GColorUtils.getDarkShades(Colors.blue);
final darkerShades = GColorUtils.getDarkShades(Colors.blue, ColorShade.normal);

// Darken or lighten colors
final darker = GColorUtils.darken(color, 0.2); // 20% darker
final lighter = GColorUtils.lighten(color, 0.1); // 10% lighter
```

### Platform Detection

```dart
import 'package:app_utils/app_utils.dart';

// Using PlatformExt class
if (PlatformExt.isDesktop) {
  // macOS, Windows, or Linux
}

if (PlatformExt.isMobile) {
  // Android or iOS
}

if (PlatformExt.isWeb) {
  // Running in browser
}

if (PlatformExt.isAIM) {
  // Android, iOS, or macOS (Apple ecosystem + Android)
}
```

## Components

### ColorShade

Enum representing Material Design color shade values.

| Value | Shade Number |
|-------|--------------|
| `lightest` | 50 |
| `secondLightest` | 100 |
| `thirdLightest` | 200 |
| `fourthLightest` | 300 |
| `fifthLightest` | 400 |
| `normal` | 500 |
| `fourthDarkest` | 600 |
| `thirdDarkest` | 700 |
| `secondDarkest` | 800 |
| `darkest` | 900 |

### GColorUtils

Static color manipulation utilities.

| Method | Description |
|--------|-------------|
| `getMaterialColor(Color)` | Convert any color to MaterialColor |
| `estimateBrightnessForColor(Color)` | Get perceived brightness (adjusted threshold) |
| `getDarkShades(Color, [ColorShade])` | Get list of dark shade variants |
| `darken(Color, [double])` | Make color darker (0.0-1.0 amount) |
| `lighten(Color, [double])` | Make color lighter (0.0-1.0 amount) |

### PlatformExt

Platform detection helper class with static getters.

| Property | Description |
|----------|-------------|
| `isDesktop` | macOS, Windows, or Linux |
| `isMobile` | Android or iOS |
| `isWeb` | Running in browser (kIsWeb) |
| `isAIM` | Android, iOS, or macOS |

## Notes

- `estimateBrightnessForColor` uses a threshold of 0.45 (vs Flutter's 0.15) to classify more colors as dark, useful for text contrast decisions
- `darken` and `lighten` use HSL color space for perceptually uniform adjustments
- The `Platform` class from `dart:io` is re-exported for convenience
