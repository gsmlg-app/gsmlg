import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'skill_registry.dart';

/// Manifest specification for Plugin 1.0.
class PluginManifest {
  PluginManifest({
    required this.name,
    required this.version,
    required this.description,
    this.schema,
  });

  final String name;
  final String version;
  final String description;
  final String? schema;

  factory PluginManifest.fromJson(Map<String, dynamic> json) {
    return PluginManifest(
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String? ?? '',
      schema: json['\$schema'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (schema != null) '\$schema': schema,
    'name': name,
    'version': version,
    'description': description,
  };
}

/// Server configuration for an MCP server bundled inside a plugin.
class PluginMcpServerConfig {
  PluginMcpServerConfig({
    required this.serverName,
    required this.type,
    required this.command,
    required this.args,
    required this.env,
  });

  final String serverName;
  final String type;
  final String command;
  final List<String> args;
  final Map<String, String> env;

  Map<String, dynamic> toJson() => {
    'type': type,
    'command': command,
    'args': args,
    'env': env,
  };
}

/// A parsed and validated Plugin 1.0 package.
class PluginPackage {
  PluginPackage({
    required this.manifest,
    required this.pluginRoot,
    required this.mcpServers,
    required this.skills,
    this.isEnabled = true,
    this.unsupportedReason,
    DateTime? installedAt,
  }) : installedAt = installedAt ?? DateTime.now();

  final PluginManifest manifest;
  final String pluginRoot;
  final Map<String, PluginMcpServerConfig> mcpServers;
  final List<SkillEntry> skills;
  bool isEnabled;
  String? unsupportedReason;
  final DateTime installedAt;

  bool get isSupported => unsupportedReason == null;

  PluginPackage clone() => PluginPackage(
    manifest: manifest,
    pluginRoot: pluginRoot,
    mcpServers: Map.of(mcpServers),
    skills: List.of(skills),
    isEnabled: isEnabled,
    unsupportedReason: unsupportedReason,
    installedAt: installedAt,
  );

  Map<String, dynamic> toSummary() => {
    'name': manifest.name,
    'version': manifest.version,
    'description': manifest.description,
    'pluginRoot': pluginRoot,
    'isEnabled': isEnabled,
    'isSupported': isSupported,
    if (unsupportedReason != null) 'unsupportedReason': unsupportedReason,
    'mcpServers': mcpServers.keys.toList(),
    'skills': skills.map((s) => s.name).toList(),
    'installedAt': installedAt.toIso8601String(),
  };
}

/// Consumer for Backplane Plugin 1.0 packages.
class PluginConsumer {
  PluginConsumer({
    String? storageDirectory,
    SkillRegistry? skillRegistry,
    bool? isMobileOverride,
  }) : _storageDirectory = storageDirectory,
       _skillRegistry = skillRegistry,
       _isMobileOverride = isMobileOverride;

  final String? _storageDirectory;
  final SkillRegistry? _skillRegistry;
  final bool? _isMobileOverride;

  String? get storageDirectory => _storageDirectory;

  /// Installed plugins keyed by plugin name.
  final Map<String, PluginPackage> _installedPlugins = {};

  /// Pinned plugin snapshots for active runs: runId -> map of plugin name to package.
  final Map<String, Map<String, PluginPackage>> _pinnedRunPlugins = {};

  bool get _isMobile =>
      _isMobileOverride ?? (Platform.isAndroid || Platform.isIOS);

  List<PluginPackage> get installedPlugins =>
      _installedPlugins.values.toList(growable: false);

  /// Loads and validates a Plugin 1.0 directory.
  Future<PluginPackage> loadFromDirectory(String pluginDirectory) async {
    final rootDir = Directory(pluginDirectory);
    if (!rootDir.existsSync()) {
      throw ArgumentError('Plugin directory "$pluginDirectory" does not exist');
    }

    final canonicalRoot = p.canonicalize(pluginDirectory);

    // 1. Parse plugin.json
    final manifestFile = File(p.join(canonicalRoot, 'plugin.json'));
    if (!manifestFile.existsSync()) {
      throw FormatException('Missing plugin.json in $canonicalRoot');
    }

    final manifestJson =
        jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>;
    final manifest = PluginManifest.fromJson(manifestJson);

    // 2. Parse mcp.json if present with ${PLUGIN_ROOT} variable expansion
    final mcpServers = <String, PluginMcpServerConfig>{};
    final mcpFile = File(p.join(canonicalRoot, 'mcp.json'));
    if (mcpFile.existsSync()) {
      final mcpJson =
          jsonDecode(await mcpFile.readAsString()) as Map<String, dynamic>;
      final serversMap = mcpJson['mcpServers'] as Map<String, dynamic>? ?? {};

      for (final entry in serversMap.entries) {
        final serverName = entry.key;
        final serverData = entry.value as Map<String, dynamic>;
        final type = (serverData['type'] as String?) ?? 'stdio';
        final rawCommand = (serverData['command'] as String?) ?? '';
        final rawArgs = (serverData['args'] as List?)?.cast<String>() ?? [];
        final rawEnv =
            (serverData['env'] as Map?)?.cast<String, dynamic>() ?? {};

        final expandedCommand = _expandPluginRoot(rawCommand, canonicalRoot);
        final expandedArgs = rawArgs
            .map((a) => _expandPluginRoot(a, canonicalRoot))
            .toList();
        final expandedEnv = rawEnv.map(
          (k, v) => MapEntry(k, _expandPluginRoot(v.toString(), canonicalRoot)),
        );

        mcpServers[serverName] = PluginMcpServerConfig(
          serverName: serverName,
          type: type,
          command: expandedCommand,
          args: expandedArgs,
          env: expandedEnv,
        );
      }
    }

    // 3. Scan skills under skills/ subdirectory
    final skills = <SkillEntry>[];
    final skillsDir = Directory(p.join(canonicalRoot, 'skills'));
    if (skillsDir.existsSync()) {
      await for (final entity in skillsDir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File &&
            p.basename(entity.path).toLowerCase() == 'skill.md') {
          final skillCanonical = p.canonicalize(entity.path);
          if (p.isWithin(canonicalRoot, skillCanonical)) {
            final name = p.basename(p.dirname(skillCanonical));
            skills.add(
              SkillEntry(
                name: name,
                description: 'Skill from plugin ${manifest.name}',
                pathToSkillMd: skillCanonical,
                source: 'plugin:${manifest.name}',
                version: manifest.version,
              ),
            );
          }
        }
      }
    }

    // 4. Platform compatibility check
    String? unsupportedReason;
    if (_isMobile && mcpServers.isNotEmpty) {
      final hasStdio = mcpServers.values.any((s) => s.type == 'stdio');
      if (hasStdio) {
        unsupportedReason =
            'Stdio MCP servers are not supported on mobile platforms';
      }
    }

    final package = PluginPackage(
      manifest: manifest,
      pluginRoot: canonicalRoot,
      mcpServers: mcpServers,
      skills: skills,
      isEnabled: unsupportedReason == null,
      unsupportedReason: unsupportedReason,
    );

    return package;
  }

  /// Installs or updates a plugin package.
  Future<PluginPackage> install(String pluginDirectory) async {
    final package = await loadFromDirectory(pluginDirectory);
    _installedPlugins[package.manifest.name] = package;

    // Register skills with skill registry if enabled
    final reg = _skillRegistry;
    if (package.isEnabled && reg != null) {
      reg.unregisterBySource('plugin:${package.manifest.name}');
      for (final skill in package.skills) {
        reg.registerSkill(skill);
      }
    }

    return package;
  }

  /// Enables an installed plugin.
  void enable(String pluginName) {
    final plugin = _installedPlugins[pluginName];
    if (plugin == null) {
      throw ArgumentError('Plugin "$pluginName" is not installed');
    }
    plugin.isEnabled = true;
    final reg = _skillRegistry;
    if (reg != null) {
      for (final skill in plugin.skills) {
        reg.registerSkill(skill);
      }
    }
  }

  /// Disables an installed plugin without deleting files.
  void disable(String pluginName) {
    final plugin = _installedPlugins[pluginName];
    if (plugin == null) {
      throw ArgumentError('Plugin "$pluginName" is not installed');
    }
    plugin.isEnabled = false;
    _skillRegistry?.unregisterBySource('plugin:$pluginName');
  }

  /// Pins an immutable snapshot of enabled plugins for an active run.
  Map<String, PluginPackage> pinPluginsForRun(String runId) {
    final snapshot = <String, PluginPackage>{};
    for (final entry in _installedPlugins.entries) {
      if (entry.value.isEnabled) {
        snapshot[entry.key] = entry.value.clone();
      }
    }
    _pinnedRunPlugins[runId] = snapshot;
    return snapshot;
  }

  /// Cleans up pinned plugin snapshots when a run completes.
  void cleanupRun(String runId) {
    _pinnedRunPlugins.remove(runId);
  }

  static String _expandPluginRoot(String template, String pluginRoot) {
    return template.replaceAll('\${PLUGIN_ROOT}', pluginRoot);
  }
}
