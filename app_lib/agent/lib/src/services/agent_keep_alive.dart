import 'dart:io' show Platform;

import 'package:app_local_llm/app_local_llm.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../repositories/gemma_repository.dart';

/// Coordinates OS background execution keep-alive while agent runs are active
/// (e.g. Android foreground service and iOS background task).
abstract interface class AgentKeepAlive {
  Future<void> onActiveRunsChanged(int activeRuns);
}

/// Mobile implementation backed by `app_local_llm`'s native foreground service
/// (Android) and background task (iOS).
///
/// Only stops the service when no agent runs remain AND no local model is
/// currently resident in [GemmaRepository].
class MobileAgentKeepAlive implements AgentKeepAlive {
  MobileAgentKeepAlive({
    required GemmaRepository gemmaRepository,
    bool? isMobileOverride,
  }) : _gemmaRepository = gemmaRepository,
       _isMobileOverride = isMobileOverride;

  final GemmaRepository _gemmaRepository;
  final bool? _isMobileOverride;
  bool _serviceStartedByAgent = false;

  bool get _isMobile =>
      _isMobileOverride ?? (!kIsWeb && (Platform.isAndroid || Platform.isIOS));

  @override
  Future<void> onActiveRunsChanged(int activeRuns) async {
    if (!_isMobile) return;
    try {
      if (activeRuns > 0) {
        final message = activeRuns == 1
            ? 'Agent task is running.'
            : '$activeRuns agent tasks are running.';
        await LocalLlm.instance.startService(
          title: 'GSMLG Agent',
          message: message,
        );
        _serviceStartedByAgent = true;
      } else if (_serviceStartedByAgent) {
        _serviceStartedByAgent = false;
        if (!_gemmaRepository.isReady) {
          await LocalLlm.instance.stopService();
        }
      }
    } catch (_) {
      // MissingPluginException in widget tests or OS background restrictions
      // must never fail an active agent run.
    }
  }
}
