import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

class PluginTab extends TabItem implements TerminalTabTitleRenamer {
  static int _nextTabNumber = 1;

  final Plugin plugin;

  final PluginManager manager;

  final int tabNumber;

  final int? shellProfileId;

  String? _customTitle;

  PluginTab(this.plugin, this.manager, {this.shellProfileId})
    : tabNumber = _nextTabNumber++ {
    manager.add(plugin);

    _updateTitle();

    plugin.title.addListener(_updateTitle);

    manager.addListener(_onPluginManagerChanged);

    content.value = PluginTabView(key: ValueKey(plugin), plugin);
  }

  @override
  void didDispose() {
    plugin.title.removeListener(_updateTitle);
    manager.removeListener(_onPluginManagerChanged);
    if (plugin.mounted) {
      manager.remove(plugin);
    }
    super.didDispose();
  }

  void _updateTitle() {
    final titleText = displayTitle;
    title.value = Row(
      mainAxisSize: MainAxisSize.min,
      children: [Flexible(child: Text(titleText, softWrap: false))],
    );
  }

  @override
  void renameTitle(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    _customTitle = trimmed;
    _updateTitle();
  }

  String get displayTitle {
    final customTitle = _customTitle;
    if (customTitle != null && customTitle.isNotEmpty) {
      return customTitle;
    }

    final workingDirectory = currentWorkingDirectory;
    final prefix = '$tabNumber';
    if (manager.hostSpec is SSHHostSpec) {
      final sshHostSpec = manager.hostSpec as SSHHostSpec;
      return '$prefix ${sshHostSpec.name} $workingDirectory';
    }
    return '$prefix $workingDirectory';
  }

  String get currentWorkingDirectory {
    return _extractWorkingDirectory(plugin.title.value);
  }

  String _extractWorkingDirectory(String? title) {
    final cleaned = _removeTerminalSize(title?.trim() ?? '');
    final directory = _parseWorkingDirectory(cleaned);
    if (directory != null) return directory;

    if (manager.hostSpec is LocalHostSpec) {
      final localHostSpec = manager.hostSpec as LocalHostSpec;
      final configuredDirectory = localHostSpec.workingDirectory;
      if (configuredDirectory != null && configuredDirectory.isNotEmpty) {
        return configuredDirectory;
      }
    }

    return '~';
  }

  String _removeTerminalSize(String title) {
    return title
        .replaceFirst(RegExp(r'\s*[—-]\s*\d+x\d+\s*$'), '')
        .replaceFirst(RegExp(r'\s+\d+x\d+\s*$'), '')
        .trim();
  }

  String? _parseWorkingDirectory(String title) {
    if (title.isEmpty) return null;
    if (_isConnectionStatus(title)) return null;
    if (_looksLikeDirectory(title)) return title;

    final colonIndex = title.lastIndexOf(':');
    if (colonIndex >= 0 && colonIndex < title.length - 1) {
      final afterColon = title.substring(colonIndex + 1).trim();
      if (_looksLikeDirectory(afterColon)) {
        return afterColon;
      }
    }

    final spaceParts = title.split(RegExp(r'\s+'));
    for (final part in spaceParts.reversed) {
      if (_looksLikeDirectory(part)) return part;
    }

    return null;
  }

  bool _isConnectionStatus(String title) {
    return switch (title) {
      'Connecting' ||
      'Terminal' ||
      'Disconnected' ||
      'Connection Failed' => true,
      _ => false,
    };
  }

  bool _looksLikeDirectory(String value) {
    if (value == '~') return true;
    return value.startsWith('~/') ||
        value.startsWith('/') ||
        RegExp(r'^[A-Za-z]:[\\/]').hasMatch(value);
  }

  void _onPluginManagerChanged() {
    if (!plugin.mounted) {
      detach();
    }
  }
}

class PluginTabView extends StatefulWidget {
  const PluginTabView(this.plugin, {super.key});

  final Plugin plugin;

  @override
  State<PluginTabView> createState() => _PluginTabViewState();
}

class _PluginTabViewState extends State<PluginTabView> {
  Plugin get plugin => widget.plugin;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !plugin.mounted) return;
      plugin.manager.connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    return plugin.build(context);
  }
}
