import 'package:flex_tabs/flex_tabs.dart';
import 'package:terminal_core/src/conn.dart';
import 'package:terminal_core/src/fs.dart';
import 'package:terminal_core/src/plugin.dart';

/// Callback type for creating a tab from a plugin.
typedef PluginTabFactory =
    TabItem Function(Plugin plugin, PluginManager manager);

/// Callback type for creating a tab from a file.
typedef FileTabFactory = TabItem Function(File file);

/// Service for managing tab operations.
///
/// Provides methods to open plugins, files, and generic tabs.
/// Requires factories to be set before use.
class TabsService {
  TabsService();

  /// Factory for creating plugin tabs. Must be set before using openPlugin.
  PluginTabFactory? pluginTabFactory;

  /// Factory for creating file tabs. Must be set before using openFile.
  FileTabFactory? fileTabFactory;

  void openPlugin(
    HostSpec host,
    Plugin plugin, {
    Tabs? tabs,
    bool activate = true,
  }) {
    if (pluginTabFactory == null) {
      throw StateError(
        'pluginTabFactory must be set before calling openPlugin',
      );
    }
    final manager = PluginManager(host);
    openTab(pluginTabFactory!(plugin, manager), tabs: tabs, activate: activate);
  }

  void openFile(File file, {Tabs? tabs, bool activate = true}) {
    if (fileTabFactory == null) {
      throw StateError('fileTabFactory must be set before calling openFile');
    }
    openTab(fileTabFactory!(file), tabs: tabs, activate: activate);
  }

  void openTab(TabItem tab, {Tabs? tabs, bool activate = true}) {
    final targetTabGroup = tabs;

    if (targetTabGroup == null) {
      return;
    }

    targetTabGroup.add(tab);

    if (activate) {
      tab.activate();
    }
  }
}
