import 'package:flutter_rust_bridge_hooks/flutter_rust_bridge_hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    await const FlutterRustBridgeNativeAssetsBuilder(
      cratePath: 'rust',
      extraCargoEnvironmentVariables: {
        'CARGO_HOME': '/tmp/isolated_cargo_home',
      },
    ).run(input: input, output: output);
  });
}
