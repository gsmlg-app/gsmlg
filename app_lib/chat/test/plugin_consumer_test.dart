import 'package:app_chat/app_chat.dart';
import 'package:test/test.dart';

void main() {
  group('PluginConsumer', () {
    test('loads Plugin 1.0 fixture with variable expansion', () async {
      final consumer = PluginConsumer();
      const fixturePath =
          '/Users/gao/Workspace/gsmlg-opt/backplane/apps/backplane_agent_runtime/examples/plugin';

      final pkg = await consumer.loadFromDirectory(fixturePath);

      expect(pkg.manifest.name, equals('backplane-example'));
      expect(pkg.manifest.version, equals('1.0.0'));
      expect(pkg.isEnabled, isTrue);

      // Verify ${PLUGIN_ROOT} variable expansion in MCP configs
      expect(pkg.mcpServers.containsKey('echo'), isTrue);
      final echo = pkg.mcpServers['echo']!;
      expect(echo.command, equals('python3'));
      expect(echo.args.first, contains('/examples/plugin/scripts/server.py'));
      expect(echo.args.first, isNot(contains('\${PLUGIN_ROOT}')));
      expect(echo.env['MARKER'], contains('/examples/plugin/skills/plugin-hello/references/marker.txt'));
      expect(echo.env['MARKER'], isNot(contains('\${PLUGIN_ROOT}')));
    });

    test('pins plugin snapshot for an active run', () async {
      final consumer = PluginConsumer();
      const fixturePath =
          '/Users/gao/Workspace/gsmlg-opt/backplane/apps/backplane_agent_runtime/examples/plugin';
      await consumer.install(fixturePath);

      final pinned = consumer.pinPluginsForRun('run_123');
      expect(pinned.containsKey('backplane-example'), isTrue);

      // Disabling after pinning does not affect the pinned snapshot
      consumer.disable('backplane-example');
      expect(consumer.installedPlugins.first.isEnabled, isFalse);
      expect(pinned['backplane-example']!.isEnabled, isTrue);

      consumer.cleanupRun('run_123');
    });
  });
}
