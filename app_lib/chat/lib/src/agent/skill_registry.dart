import 'dart:async';
import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:path/path.dart' as p;

import '../services/tool_executor.dart';

/// Metadata for a discovered and indexed skill.
class SkillEntry {
  SkillEntry({
    required this.name,
    required this.description,
    required this.pathToSkillMd,
    this.source = 'directory',
    this.version = '1.0.0',
    this.allowedTools,
    this.requiredPlatform,
  });

  final String name;
  final String description;
  final String pathToSkillMd;
  final String source;
  final String version;
  final Set<String>? allowedTools;
  final String? requiredPlatform;

  DirectorySkillMetadata toDirectorySkillMetadata() => DirectorySkillMetadata(
    name: name,
    description: description,
    pathToSkillMd: pathToSkillMd,
  );
}

/// Registry that discovers, indexes, and loads skills on demand.
class SkillRegistry {
  SkillRegistry({
    List<String>? rootPaths,
  }) : _rootPaths = rootPaths ?? [];

  final List<String> _rootPaths;
  final Map<String, SkillEntry> _skills = {};

  List<SkillEntry> get skills => _skills.values.toList(growable: false);

  static const _readSkillTool = 'read_skill';
  static const _listSkillsTool = 'list_skills';

  bool handlesTool(String toolName) => {
    _readSkillTool,
    _listSkillsTool,
  }.contains(toolName);

  List<ChatToolDefinition> get toolDefinitions => [
    const ChatToolDefinition(
      name: _readSkillTool,
      description: 'Read detailed instructions for a skill from its SKILL.md file on demand.',
      parameters: {
        'type': 'object',
        'properties': {
          'name': {
            'type': 'string',
            'description': 'The name of the skill to read.',
          },
        },
        'required': ['name'],
      },
    ),
    const ChatToolDefinition(
      name: _listSkillsTool,
      description: 'List all available skills with their names and descriptions.',
      parameters: {
        'type': 'object',
        'properties': {},
      },
    ),
  ];

  /// Scans all configured root paths and indexes discovered skills.
  Future<void> scanRoots() async {
    for (final root in _rootPaths) {
      await indexDirectory(root);
    }
  }

  /// Indexes skills in a given directory safely.
  Future<void> indexDirectory(String directoryPath, {String source = 'directory'}) async {
    final dir = Directory(directoryPath);
    if (!dir.existsSync()) return;

    final canonicalRoot = p.canonicalize(directoryPath);

    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File && p.basename(entity.path).toLowerCase() == 'skill.md') {
        final canonicalPath = p.canonicalize(entity.path);
        // Guard against directory traversal escaping the root
        if (!p.isWithin(canonicalRoot, canonicalPath) && canonicalPath != canonicalRoot) {
          continue;
        }

        try {
          final content = await entity.readAsString();
          final entry = _parseSkillFile(canonicalPath, content, source: source);
          if (entry != null) {
            _skills[entry.name] = entry;
          }
        } catch (_) {}
      }
    }
  }

  /// Registers an explicit skill entry (e.g. from an installed plugin).
  void registerSkill(SkillEntry entry) {
    _skills[entry.name] = entry;
  }

  /// Unregisters skills with the specified source (e.g. uninstalled plugin).
  void unregisterBySource(String source) {
    _skills.removeWhere((_, skill) => skill.source == source);
  }

  /// Reads the on-demand content of a skill markdown.
  Future<String> readSkillContent(String name) async {
    final skill = _skills[name];
    if (skill == null) {
      throw ArgumentError('Skill "$name" not found in registry');
    }
    final file = File(skill.pathToSkillMd);
    if (!file.existsSync()) {
      throw StateError('Skill file "${skill.pathToSkillMd}" not found');
    }
    return await file.readAsString();
  }

  Future<dynamic> executeTool({
    required String toolName,
    required Map<String, dynamic> arguments,
  }) async {
    switch (toolName) {
      case _readSkillTool:
        final name = arguments['name'] as String;
        try {
          final content = await readSkillContent(name);
          return {'name': name, 'content': content};
        } catch (e) {
          return {'error': e.toString()};
        }
      case _listSkillsTool:
        return {
          'skills': _skills.values.map((s) => {
            'name': s.name,
            'description': s.description,
            'source': s.source,
            'version': s.version,
          }).toList(),
        };
      default:
        return {'error': 'Unknown skill tool: $toolName'};
    }
  }

  SkillEntry? _parseSkillFile(String filePath, String content, {required String source}) {
    String? name;
    String? description;
    String? version;
    String? platform;
    Set<String>? allowedTools;

    final lines = content.split('\n');
    if (lines.isNotEmpty && lines.first.trim() == '---') {
      var inFrontmatter = true;
      for (var i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line == '---') {
          inFrontmatter = false;
          break;
        }
        if (!inFrontmatter) break;

        final colonIdx = line.indexOf(':');
        if (colonIdx > 0) {
          final key = line.substring(0, colonIdx).trim().toLowerCase();
          final val = line.substring(colonIdx + 1).trim().replaceAll('"', '').replaceAll("'", '');
          if (key == 'name') name = val;
          if (key == 'description') description = val;
          if (key == 'version') version = val;
          if (key == 'platform') platform = val;
          if (key == 'tools' || key == 'allowed-tools') {
            allowedTools = val.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toSet();
          }
        }
      }
    }

    // Fallback: derive name from directory if missing in frontmatter
    name ??= p.basename(p.dirname(filePath));
    description ??= 'No description provided';

    return SkillEntry(
      name: name,
      description: description,
      pathToSkillMd: filePath,
      source: source,
      version: version ?? '1.0.0',
      allowedTools: allowedTools,
      requiredPlatform: platform,
    );
  }
}
