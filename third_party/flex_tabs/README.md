# Flex Tabs

A Flutter package for flexible tab management with document-based state handling.

## Features

- **Tab Groups**: Manage collections of tabs with automatic activation handling
- **Tab Items**: Extensible tab model with title, content, and lifecycle callbacks
- **Document Model**: Tree-based document structure for complex layouts
- **Theming**: Customizable theme support via `FlexTabsTheme`
- **Tab Views**: Built-in `TabsView` widget for rendering tab groups

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flex_tabs:
    path: ../third_party/flex_tabs
```

## Usage

### Basic Tab Management

```dart
import 'package:flex_tabs/flex_tabs.dart';

// Create a tab group
final tabs = Tabs();

// Add tabs
tabs.add(TabItem(
  title: Text('Tab 1'),
  content: Container(child: Text('Content 1')),
));

tabs.add(TabItem(
  title: Text('Tab 2'),
  content: Container(child: Text('Content 2')),
));

// Activate a tab
tabs.activate(tabs.children.first);

// Remove a tab
tabs.remove(tabs.children.last);
```

### Custom Tab Items

```dart
class MyTab extends TabItem {
  MyTab() : super(
    title: Text('My Tab'),
    content: MyContent(),
  );

  @override
  void didMount() {
    // Called when tab is added to document
  }

  @override
  void didActivate() {
    // Called when tab becomes active
  }

  @override
  void didDeactivate() {
    // Called when tab becomes inactive
  }

  @override
  void didUnmount() {
    // Called when tab is removed from document
  }

  @override
  void didDispose() {
    // Called when tab is permanently closed
  }
}
```

### Document Model

```dart
// Create a document to manage tabs
final document = TabsDocument();

// Set root tabs group
document.setRoot(tabs);

// Access active tab
final active = document.activeTab.value;
```

## Components

### TabItem

Base class for tabs with title and content.

| Property/Method | Description |
|-----------------|-------------|
| `title` | `ValueNotifier<Widget?>` for tab title |
| `content` | `ValueNotifier<Widget?>` for tab content |
| `isActivated` | Whether this tab is currently active |
| `parent` | Parent `Tabs` container |
| `activate()` | Make this tab active |
| `detach()` | Remove from parent |
| `dispose()` | Permanently close tab |
| `replace(TabItem)` | Replace with another tab |

### Tabs

Container for managing a group of tabs.

| Property/Method | Description |
|-----------------|-------------|
| `children` | List of child `TabItem`s |
| `activeTab` | Currently active tab |
| `add(TabItem)` | Add a tab |
| `remove(TabItem)` | Remove a tab |
| `activate(TabItem)` | Make a tab active |
| `replace(old, new)` | Replace one tab with another |

### TabsDocument

Document model for complex tab layouts.

| Property/Method | Description |
|-----------------|-------------|
| `root` | Root node of the document tree |
| `activeTab` | `ValueNotifier` for global active tab |
| `setRoot(node)` | Set the root tabs node |

### TabsView

Widget for rendering tab groups with theming.

### FlexTabsTheme

Inherited widget for tab theming configuration.

## Lifecycle Callbacks

Tabs support these lifecycle callbacks:

1. `didMount()` - Tab added to a document
2. `didActivate()` - Tab became active
3. `didDeactivate()` - Tab became inactive
4. `didUnmount()` - Tab removed from document
5. `didDispose()` - Tab permanently closed

## Active Tab History

The `Tabs` container maintains an activation history. When the active tab is closed, the previously active tab is automatically activated.
