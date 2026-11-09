import 'package:flutter_rust_bridge_hooks/flutter_rust_bridge_hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    await const FlutterRustBridgeNativeAssetsBuilder(
      cratePath: 'rust',
      // Match ios/Runner's deployment target. Without it rustc links iOS at
      // 10.0 while DuckDB's C++ needs `___chkstk_darwin` (iOS 13+).
      extraCargoEnvironmentVariables: {'IPHONEOS_DEPLOYMENT_TARGET': '17.0'},
    ).run(input: input, output: output);
  });
}
