import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// How the agent should trust the SecretHub Core server certificate.
///
/// Mirrors `AgentTrust` in the secrethub_agent plugin design (DESIGN.md §12).
enum SecretHubTrust { system, pinnedCa }

/// One configured secret: an app-local [alias] mapped to a Core secret [path].
///
/// Mirrors `SecretBinding` in the plugin design.
class SecretHubBinding {
  const SecretHubBinding({
    required this.alias,
    required this.path,
    this.allowOffline = false,
  });

  final String alias;
  final String path;
  final bool allowOffline;

  Map<String, Object?> toJson() => {
    'alias': alias,
    'path': path,
    'allowOffline': allowOffline,
  };

  factory SecretHubBinding.fromJson(Map<String, Object?> json) =>
      SecretHubBinding(
        alias: json['alias'] as String? ?? '',
        path: json['path'] as String? ?? '',
        allowOffline: json['allowOffline'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) =>
      other is SecretHubBinding &&
      other.alias == alias &&
      other.path == path &&
      other.allowOffline == allowOffline;

  @override
  int get hashCode => Object.hash(alias, path, allowOffline);
}

/// App-side SecretHub Agent configuration, persisted on the device.
///
/// Holds only connection settings and alias→path bindings. Private keys,
/// bootstrap tokens and secret values never belong here: the plugin keeps the
/// installation identity in the platform keystore.
class SecretHubAgentConfig {
  const SecretHubAgentConfig({
    this.coreUrl = '',
    this.trust = SecretHubTrust.system,
    this.pinnedCaPem,
    this.bindings = const [],
  });

  static const prefsKey = 'secrethub_agent_config';

  final String coreUrl;
  final SecretHubTrust trust;
  final String? pinnedCaPem;
  final List<SecretHubBinding> bindings;

  bool get isEmpty => coreUrl.trim().isEmpty && bindings.isEmpty;

  SecretHubAgentConfig copyWith({
    String? coreUrl,
    SecretHubTrust? trust,
    String? pinnedCaPem,
    bool clearPinnedCaPem = false,
    List<SecretHubBinding>? bindings,
  }) => SecretHubAgentConfig(
    coreUrl: coreUrl ?? this.coreUrl,
    trust: trust ?? this.trust,
    pinnedCaPem: clearPinnedCaPem ? null : (pinnedCaPem ?? this.pinnedCaPem),
    bindings: bindings ?? this.bindings,
  );

  /// Validation problems, empty when the config can be saved.
  List<SecretHubConfigError> validate() {
    final errors = <SecretHubConfigError>[];
    final uri = Uri.tryParse(coreUrl.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      errors.add(SecretHubConfigError.invalidCoreUrl);
    }
    if (trust == SecretHubTrust.pinnedCa &&
        !(pinnedCaPem ?? '').contains('-----BEGIN CERTIFICATE-----')) {
      errors.add(SecretHubConfigError.invalidPinnedCa);
    }
    final aliases = <String>{};
    for (final binding in bindings) {
      final alias = binding.alias.trim();
      if (alias.isEmpty || binding.path.trim().isEmpty) {
        errors.add(SecretHubConfigError.incompleteBinding);
      } else if (!aliases.add(alias)) {
        errors.add(SecretHubConfigError.duplicateAlias);
      }
    }
    return errors.toSet().toList();
  }

  Map<String, Object?> toJson() => {
    'coreUrl': coreUrl.trim(),
    'trust': trust.name,
    if (trust == SecretHubTrust.pinnedCa) 'pinnedCaPem': pinnedCaPem,
    'bindings': [
      for (final b in bindings)
        SecretHubBinding(
          alias: b.alias.trim(),
          path: b.path.trim(),
          allowOffline: b.allowOffline,
        ).toJson(),
    ],
  };

  factory SecretHubAgentConfig.fromJson(Map<String, Object?> json) =>
      SecretHubAgentConfig(
        coreUrl: json['coreUrl'] as String? ?? '',
        trust: SecretHubTrust.values.firstWhere(
          (t) => t.name == json['trust'],
          orElse: () => SecretHubTrust.system,
        ),
        pinnedCaPem: json['pinnedCaPem'] as String?,
        bindings: [
          for (final b in json['bindings'] as List? ?? const [])
            if (b is Map) SecretHubBinding.fromJson(b.cast<String, Object?>()),
        ],
      );

  /// Reads the saved config; a missing or unreadable value yields defaults.
  static SecretHubAgentConfig load(SharedPreferences prefs) {
    final raw = prefs.getString(prefsKey);
    if (raw == null) return const SecretHubAgentConfig();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return SecretHubAgentConfig.fromJson(decoded.cast<String, Object?>());
      }
    } on FormatException {
      // Fall through to defaults.
    }
    return const SecretHubAgentConfig();
  }

  Future<bool> save(SharedPreferences prefs) =>
      prefs.setString(prefsKey, jsonEncode(toJson()));
}

enum SecretHubConfigError {
  invalidCoreUrl,
  invalidPinnedCa,
  incompleteBinding,
  duplicateAlias,
}
