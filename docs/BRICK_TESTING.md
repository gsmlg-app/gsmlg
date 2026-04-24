# Mason Brick Testing

## How Bricks Are Tested

Each Mason brick under `bricks/` includes a test file template in its `__brick__/test/` directory. When you generate a new package with `mason make`, the test file is scaffolded alongside the source code.

For example, `mason make simple_bloc --name=todo` generates `app_bloc/todo/test/todo_bloc_test.dart` with a `bloc_test`-based test skeleton.

## Bricks with Test Templates

| Brick | Generated Test File |
|-------|-------------------|
| `simple_bloc` | `test/{{name}}_bloc_test.dart` |
| `list_bloc` | `test/{{name}}_list_bloc_test.dart` |
| `form_bloc` | `test/{{name}}_form_bloc_test.dart` |
| `api_client` | `test/{{package_name}}_test.dart` |
| `widget` | `test/{{name}}_widget_test.dart` |

The `screen`, `repository`, `native_plugin`, and `native_federation_plugin` bricks do not generate test files.

## Running Tests After Generation

After generating a new package:

```bash
# Register the new package in root pubspec.yaml workspace: list
# Then bootstrap
melos bootstrap

# Run tests for the specific package
cd app_bloc/my_feature && dart test

# Or run all tests
melos run test
```

## Validating Brick Templates

To verify a brick generates valid Dart code:

```bash
# Generate into a temp directory
mason make simple_bloc --name=test_feature -o /tmp/brick_test

# Check that it analyzes cleanly
cd /tmp/brick_test/test_feature && dart pub get && dart analyze
```
