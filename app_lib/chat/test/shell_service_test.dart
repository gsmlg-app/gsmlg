import 'dart:io';

import 'package:app_chat/app_chat.dart';
import 'package:test/test.dart';

void main() {
  group('ShellExecutionService', () {
    late ShellExecutionService service;

    setUp(() {
      service = ShellExecutionService();
    });

    tearDown(() async {
      await service.cleanupRun('test_run');
    });

    test('executes short command and captures output on desktop', () async {
      if (Platform.isAndroid || Platform.isIOS) return;

      final res = await service.executeTool(
        toolName: 'exec_command',
        arguments: {
          'command': Platform.isWindows ? 'cmd.exe' : '/bin/sh',
          'args': Platform.isWindows ? ['/c', 'echo GSMLG_SHELL_OK'] : ['-c', 'echo GSMLG_SHELL_OK'],
          'waitForOutput': 3000,
        },
        runId: 'test_run',
        sessionId: 'session_1',
      );

      expect(res, isA<Map<String, dynamic>>());
      final map = res as Map<String, dynamic>;
      expect(map['status'], equals('completed'));
      expect(map['output'], contains('GSMLG_SHELL_OK'));
      expect(map['exitCode'], equals(0));
      expect(map['isRunning'], isFalse);
    });

    test('mobile capability override rejects local execution with explicit error', () async {
      final mobileService = ShellExecutionService(isMobileOverride: true);

      final res = await mobileService.executeTool(
        toolName: 'exec_command',
        arguments: {
          'command': 'ls',
          'host': 'local',
        },
        runId: 'mobile_run',
        sessionId: 'session_1',
      );

      expect(res, isA<Map<String, dynamic>>());
      final map = res as Map<String, dynamic>;
      expect(map['supported'], isFalse);
      expect(map['error'], contains('Local shell execution is not supported on mobile'));
    });

    test('supports incremental output reading via cursor', () async {
      if (Platform.isAndroid || Platform.isIOS) return;

      // Start long-running or multi-line command with short waitForOutput
      final res = await service.executeTool(
        toolName: 'exec_command',
        arguments: {
          'command': Platform.isWindows ? 'cmd.exe' : '/bin/sh',
          'args': Platform.isWindows ? ['/c', 'echo line1 && echo line2'] : ['-c', 'echo line1 && echo line2'],
          'waitForOutput': 3000,
        },
        runId: 'test_run',
        sessionId: 'session_1',
      );

      final map = res as Map<String, dynamic>;
      final sessionId = map['sessionId'] as String;

      final readRes = await service.executeTool(
        toolName: 'read_process_output',
        arguments: {
          'sessionId': sessionId,
          'cursor': 0,
        },
        runId: 'test_run',
        sessionId: 'session_1',
      );

      expect(readRes['output'], contains('line1'));
      expect(readRes['cursor'], greaterThan(0));
    });

    test('terminate_session stops running process', () async {
      if (Platform.isAndroid || Platform.isIOS) return;

      // Spawn a sleep process
      final res = await service.executeTool(
        toolName: 'exec_command',
        arguments: {
          'command': Platform.isWindows ? 'cmd.exe' : '/bin/sh',
          'args': Platform.isWindows ? ['/c', 'ping -n 10 127.0.0.1'] : ['-c', 'sleep 10'],
          'waitForOutput': 100, // Background it quickly
        },
        runId: 'test_run',
        sessionId: 'session_1',
      );

      final map = res as Map<String, dynamic>;
      final sessionId = map['sessionId'] as String;

      final termRes = await service.executeTool(
        toolName: 'terminate_session',
        arguments: {
          'sessionId': sessionId,
        },
        runId: 'test_run',
        sessionId: 'session_1',
      );

      expect(termRes['status'], equals('terminated'));
      expect(termRes['terminated'], isTrue);
    });
  });
}
