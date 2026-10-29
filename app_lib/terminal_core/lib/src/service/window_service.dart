import 'package:window_manager/window_manager.dart';

/// Service for managing application window operations.
class WindowService {
  Future<void> createWindow() async {
    // TODO: Implement window creation
    // final executable = Platform.resolvedExecutable;
    // await Process.start(executable, [], mode: ProcessStartMode.detached);
  }

  Future<void> setTitle(String title) async {
    await windowManager.setTitle(title);
  }
}
