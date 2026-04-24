# Form Management

## Overview

Forms in this project use two approaches:

1. **DuskMoon Form** (`duskmoon_form` package) -- the UI form widget library used by `app_form/` packages
2. **Form BLoC brick** (`bricks/form_bloc/`) -- a Mason brick for generating form-specific BLoC packages with validation

## DuskMoon Form

The `camera_settings_form` package (`app_form/camera_settings/`) demonstrates the pattern. It depends on `duskmoon_form` for form widgets and uses a BLoC for state management.

```
app_form/camera_settings/
├── lib/
│   ├── camera_settings_form.dart          # barrel export
│   └── src/
│       ├── bloc/camera_settings_form_bloc.dart   # form BLoC
│       └── widget/camera_settings_form_widget.dart  # form UI
└── test/
    └── camera_settings_form_test.dart
```

### Adding a New Form Module

```bash
# Use the form_bloc brick to generate the BLoC
mason make form_bloc --name=login --fields "email:email,password:password" -o app_form

# Add the new package to root pubspec.yaml workspace: list
# Run melos bootstrap
```

## Form BLoC Brick

The `form_bloc` brick generates a complete BLoC package for form state management.

### Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `name` | `login` | Form name |
| `output_directory` | `app_bloc` | Output directory |
| `fields` | `["email:email", "password:password"]` | Fields as `"name:type"` pairs |

### Supported Field Types

`text`, `email`, `password`, `number`, `boolean`, `select`, `multiselect`, `date`, `file`

### Generated Files

```
{{name}}_form_bloc/
├── lib/
│   ├── {{name}}_form_bloc.dart    # barrel export
│   └── src/
│       ├── bloc.dart              # BLoC with validation logic
│       ├── event.dart             # form events (field changes, submit, reset)
│       └── state.dart             # form state with per-field validation
└── test/
    └── {{name}}_form_bloc_test.dart
```

### Usage

```dart
// Add the generated form BLoC to MainProvider
BlocProvider<LoginFormBloc>(
  create: (context) => LoginFormBloc(),
),

// Use in a widget
BlocBuilder<LoginFormBloc, LoginFormState>(
  builder: (context, state) {
    return Column(
      children: [
        TextField(
          onChanged: (value) =>
              context.read<LoginFormBloc>().add(EmailChanged(value)),
          decoration: InputDecoration(errorText: state.emailError),
        ),
        // ...
      ],
    );
  },
)
```
