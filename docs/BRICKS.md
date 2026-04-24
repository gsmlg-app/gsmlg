# Mason Bricks Guide

This project uses [Mason](https://pub.dev/packages/mason_cli) for code generation. All bricks are at version `0.1.0+1` and target Mason `^0.1.1`.

```bash
dart pub global activate mason_cli
mason get
```

## Available Bricks

| Brick | Description | Output |
|-------|-------------|--------|
| `screen` | Screen with GoRouter + adaptive scaffold | `lib/screens/` |
| `widget` | Reusable widget package | `app_widget/` |
| `simple_bloc` | Basic BLoC package | `app_bloc/` |
| `list_bloc` | List BLoC with pagination, search, filtering | `app_bloc/` |
| `form_bloc` | Form BLoC with dynamic field generation | `app_bloc/` or `app_form/` |
| `repository` | Repository pattern with data sources | standalone package |
| `api_client` | OpenAPI client with Dio/Retrofit | `app_api/` |
| `native_plugin` | Single-package native plugin | `app_plugin/` |
| `native_federation_plugin` | Federated native plugin (multi-package) | `app_plugin/` |

---

### screen

Generates a single screen file. Simplest brick.

```bash
mason make screen --name Profile --folder user
```

| Variable | Default | Description |
|----------|---------|-------------|
| `name` | `Profile` | Screen name |
| `package_name` | `my_app` | Main app package for imports |
| `has_adaptive_scaffold` | `true` | Use AppAdaptiveScaffold |
| `has_app_bar` | `true` | Include SliverAppBar |

Generates: `lib/screens/{folder}/{name}_screen.dart` with static `name`/`path` constants for GoRouter.

---

### widget

Generates a standalone widget package.

```bash
mason make widget --name CustomButton --type stateless --folder components
```

| Variable | Default | Description |
|----------|---------|-------------|
| `name` | `CustomButton` | Widget name |
| `type` | `stateless` | `stateless` or `stateful` |
| `folder` | `""` | Subfolder in app_widget |
| `has_platform_adaptive` | `true` | Material vs Cupertino branching |

Generates: package with `lib/`, `test/`, `pubspec.yaml`, `analysis_options.yaml`.

---

### simple_bloc

Generates a minimal BLoC package. Uses Dart 3 sealed classes and Equatable.

```bash
mason make simple_bloc -o app_bloc/feature_name --name=feature_name
```

| Variable | Default | Description |
|----------|---------|-------------|
| `name` | `todo` | BLoC name |

Generates:
```
{name}_bloc/
├── lib/src/bloc.dart, event.dart, state.dart
├── lib/{name}_bloc.dart  (barrel export)
├── test/{name}_bloc_test.dart
└── pubspec.yaml
```

---

### list_bloc

Feature-rich list management BLoC. Uses Mustache conditionals so generated code only includes enabled features.

```bash
mason make list_bloc --name Users --item_type User -o app_bloc
```

| Variable | Default | Description |
|----------|---------|-------------|
| `name` | `users` | List name |
| `item_type` | `User` | Item type (singular) |
| `has_pagination` | `true` | Pagination support |
| `has_search` | `true` | Search functionality |
| `has_filters` | `true` | Advanced filtering |
| `has_reorder` | `false` | Drag-and-drop reordering |
| `has_crud` | `true` | CRUD operations |
| `filter_types` | `["category", "status"]` | Filter types |
| `sort_options` | `["name", "date"]` | Sort options |
| `output_directory` | `app_bloc` | Output directory |

Additional generated files beyond simple_bloc: `schema.dart` (field configuration), `item_state.dart` (per-item state tracking).

---

### form_bloc

Generates a form-specific BLoC with per-field validation.

```bash
mason make form_bloc --name=login --fields "email:email,password:password" -o app_form
```

| Variable | Default | Description |
|----------|---------|-------------|
| `name` | `login` | Form name |
| `output_directory` | `app_bloc` | Output directory |
| `fields` | `["email:email", "password:password"]` | Fields as `"name:type"` pairs |

Field types: `text`, `email`, `password`, `number`, `boolean`, `select`, `multiselect`, `date`, `file`.

See [FORM_BLOC.md](FORM_BLOC.md) for detailed usage.

---

### repository

Generates a repository package with optional remote/local data sources.

```bash
mason make repository --name User
```

| Variable | Default | Description |
|----------|---------|-------------|
| `name` | `user` | Repository name |
| `has_remote_data_source` | `true` | Include API data source |
| `has_local_data_source` | `true` | Include local storage data source |
| `model_name` | `{{name.pascalCase()}}` | Model class name |

Generates: `repository.dart`, `models/`, `data_sources/`, `exceptions/`.

---

### api_client

Scaffolds an API client package for OpenAPI/Swagger code generation with Dio and Retrofit.

```bash
mason make api_client -o app_api/app_api --package_name=app_api
```

| Variable | Default | Description |
|----------|---------|-------------|
| `package_name` | `app_api` | Package name |

After generation, replace the placeholder `openapi.yaml` with your real spec and run `dart run swagger_parser`.

---

### native_plugin

Single-package native plugin (simpler alternative to federated).

```bash
mason make native_plugin --name plugin_name --description "Description" --package_prefix app -o app_plugin
```

| Variable | Default | Description |
|----------|---------|-------------|
| `name` | _(required)_ | Plugin name |
| `description` | _(required)_ | Plugin description |
| `package_prefix` | `app` | Package name prefix |
| `author` | `GSMLG Team` | Author |
| `support_android/ios/linux/macos/windows` | `true` | Platform toggles |
| `support_web` | `false` | Web platform toggle |

Native implementations: Kotlin (Android), Swift (iOS/macOS), C++ (Linux/Windows).

---

### native_federation_plugin

Full federated plugin following Flutter's official plugin architecture. Generates 7 sub-packages.

```bash
mason make native_federation_plugin --name client_info --description "Client info plugin" --package_prefix app -o app_plugin
```

Same variables as `native_plugin`.

Generates a multi-package structure:
- `{name}/` -- app-facing package
- `{name}_platform_interface/` -- abstract platform interface + method channel
- `{name}_android/` -- Kotlin implementation
- `{name}_ios/` -- Swift implementation (iOS)
- `{name}_linux/` -- C++ implementation
- `{name}_macos/` -- Swift implementation (macOS)
- `{name}_windows/` -- C++ implementation

**Post-generation:** add all sub-packages to root `pubspec.yaml` `workspace:` list, add `resolution: workspace` to each sub-package's pubspec, then `melos bootstrap`.

---

## Post-Generation Checklist

For any brick that generates a new package:

1. Add the package to root `pubspec.yaml` `workspace:` list
2. Add the package name to root `pubspec.yaml` `dependencies:` with `any`
3. Run `melos bootstrap`
4. If it's a BLoC, register it in `MainProvider` (`app_lib/provider/lib/src/main.dart`)
5. Review and adjust generated code as needed
