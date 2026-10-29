import 'dart:async';

import 'package:flutter/material.dart';
import 'package:terminal_core/terminal_core.dart';

class StarterPlugin extends Plugin {
  final _uptime = ValueNotifier<String?>(null);

  Future<void> _updateUptime() async {
    try {
      final result = await host.execute('uptime');
      _uptime.value = result.stdout;
    } catch (error) {
      _uptime.value = 'Error: $error';
    }
  }

  Future<void> _startUpdate() async {
    while (connected) {
      await _updateUptime();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  void didMounted() {
    title.value = 'Uptime';
    super.didMounted();
  }

  @override
  void didConnected() {
    _startUpdate();
    super.didConnected();
  }

  @override
  void didDisconnected() {
    _uptime.value = 'Disconnected';
    super.didDisconnected();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: ValueListenableBuilder<String?>(
          valueListenable: _uptime,
          builder: (context, value, child) {
            return Text(value ?? 'Waiting...');
          },
        ),
      ),
    );
  }
}
