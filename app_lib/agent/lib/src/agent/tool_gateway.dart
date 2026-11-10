import 'dart:async';
import 'dart:convert';

import 'package:app_logging/app_logging.dart' show LogContext;
import 'package:dart_agent_core/dart_agent_core.dart';

import '../services/tool_executor.dart';
import 'agent_event.dart';
import 'agent_invocation.dart';
import 'memory_provider.dart';
import 'shell_service.dart';
import 'skill_registry.dart';
import 'sub_agent_supervisor.dart';

/// Callback to persist or handle an audited tool receipt immediately.
typedef ToolReceiptHandler =
    Future<void> Function(ToolInvocationReceipt receipt);

/// A single application-owned gateway for tool discovery, validation,
/// capability enforcement, execution journaling, and serial/concurrent dispatch.
class ToolExecutionGateway {
  ToolExecutionGateway({
    ToolExecutor? toolExecutor,
    ShellExecutionService? shellService,
    AgentSupervisor? subAgentSupervisor,
    ScopedMemoryProvider? memoryProvider,
    SkillRegistry? skillRegistry,
    this.onEvent,
    this.onReceipt,
    Set<String>? allowedTools,
    bool awaitAcknowledgements = false,
  }) : _toolExecutor = toolExecutor,
       _awaitAcknowledgements = awaitAcknowledgements,
       _shellService = shellService,
       _subAgentSupervisor = subAgentSupervisor,
       _memoryProvider = memoryProvider,
       _skillRegistry = skillRegistry,
       _allowedTools = allowedTools;

  final ToolExecutor? _toolExecutor;
  final ShellExecutionService? _shellService;
  final AgentSupervisor? _subAgentSupervisor;
  final ScopedMemoryProvider? _memoryProvider;
  final SkillRegistry? _skillRegistry;
  final Set<String>? _allowedTools;

  /// Whether a tool call waits for its [ToolCallCompletedEvent] to be
  /// acknowledged before returning its result to the model.
  final bool _awaitAcknowledgements;
  final void Function(ChatAgentEvent event)? onEvent;
  final ToolReceiptHandler? onReceipt;

  /// Per-run serial locks for mutating tools.
  final Map<String, Future<void>> _runLocks = {};

  /// Prepared calls mapped by `${runId}:${callId}`.
  final Map<String, FunctionCall> _preparedCalls = {};

  /// Set of tool names known to be safely parallel and read-only.
  static const Set<String> _readOnlyTools = {
    'whois_lookup',
    'ip_geolocation',
    'web_fetch',
    'web_search',
    'domain_list_zones',
    'domain_list_records',
    'vultr_list_servers',
    'read_process_output',
    'memory_search',
    'read_skill',
    'list_skills',
  };

  bool isReadOnly(String toolName) => _readOnlyTools.contains(toolName);

  /// Returns all available `dart_agent_core.Tool` definitions exposed by the gateway.
  List<Tool> getTools({required String runId, required String sessionId}) {
    final definitions = <Tool>[];

    // 1. Built-in and MCP tools from ToolExecutor
    if (_toolExecutor != null) {
      for (final def in _toolExecutor.toolDefinitions) {
        if (_isToolAllowed(def.name)) {
          definitions.add(
            _createTool(
              runId: runId,
              sessionId: sessionId,
              name: def.name,
              description: def.description,
              parameters: def.parameters,
            ),
          );
        }
      }
    }

    // 2. Shell tools from ShellExecutionService
    if (_shellService != null) {
      for (final def in _shellService.toolDefinitions) {
        if (_isToolAllowed(def.name)) {
          definitions.add(
            _createTool(
              runId: runId,
              sessionId: sessionId,
              name: def.name,
              description: def.description,
              parameters: def.parameters,
            ),
          );
        }
      }
    }

    // 3. Sub-agent delegation tools from AgentSupervisor
    if (_subAgentSupervisor != null) {
      for (final def in _subAgentSupervisor.toolDefinitions) {
        if (_isToolAllowed(def.name)) {
          definitions.add(
            _createTool(
              runId: runId,
              sessionId: sessionId,
              name: def.name,
              description: def.description,
              parameters: def.parameters,
            ),
          );
        }
      }
    }

    // 4. Memory tools from ScopedMemoryProvider
    if (_memoryProvider != null) {
      for (final def in _memoryProvider.toolDefinitions) {
        if (_isToolAllowed(def.name)) {
          definitions.add(
            _createTool(
              runId: runId,
              sessionId: sessionId,
              name: def.name,
              description: def.description,
              parameters: def.parameters,
            ),
          );
        }
      }
    }

    // 5. Skill tools from SkillRegistry
    if (_skillRegistry != null) {
      for (final def in _skillRegistry.toolDefinitions) {
        if (_isToolAllowed(def.name)) {
          definitions.add(
            _createTool(
              runId: runId,
              sessionId: sessionId,
              name: def.name,
              description: def.description,
              parameters: def.parameters,
            ),
          );
        }
      }
    }

    return definitions;
  }

  bool _isToolAllowed(String name) {
    if (_allowedTools == null) return true;
    return _allowedTools.contains(name);
  }

  Tool _createTool({
    required String runId,
    required String sessionId,
    required String name,
    required String description,
    required Map<String, dynamic> parameters,
  }) {
    return Tool(
      name: name,
      description: description,
      parameters: parameters,
      parameterMode: ToolParameterMode.object,
      executable: (Map<String, dynamic> args) async {
        return await execute(
          runId: runId,
          sessionId: sessionId,
          toolName: name,
          arguments: args,
        );
      },
    );
  }

  /// Called by hook when a function call is prepared.
  Future<void> onPreparedCall(
    String runId,
    String sessionId,
    FunctionCall call,
  ) async {
    final key = '$runId:${call.id}';
    _preparedCalls[key] = call;

    onEvent?.call(
      ToolCallPreparedEvent(
        runId: runId,
        sessionId: sessionId,
        callId: call.id,
        toolName: call.name,
        arguments: call.arguments,
      ),
    );
  }

  /// Executes a tool call within the gateway.
  Future<AgentToolResult> execute({
    required String runId,
    required String sessionId,
    required String toolName,
    required Map<String, dynamic> arguments,
  }) async {
    final context = AgentCallToolContext.current;
    final cancelToken = context?.cancelToken;
    final rawArguments = jsonEncode(arguments);
    final stopwatch = Stopwatch()..start();
    var backend = 'none';

    // Find call ID if prepared, otherwise generate stable ID
    var callId = 'call_${DateTime.now().microsecondsSinceEpoch}';
    for (final entry in _preparedCalls.entries) {
      if (entry.key.startsWith('$runId:') && entry.value.name == toolName) {
        callId = entry.value.id;
        break;
      }
    }

    // 1. Immediate pre-dispatch cancellation check
    if (cancelToken?.isCancelled ?? false) {
      final receipt = ToolInvocationReceipt(
        runId: runId,
        callId: callId,
        invocationId: callId,
        toolName: toolName,
        arguments: rawArguments,
        status: InvocationStatus.cancelled,
        isError: true,
        result: 'Cancelled before execution',
        timestamp: DateTime.now(),
        backend: backend,
        durationMs: stopwatch.elapsedMilliseconds,
      );
      await _recordReceipt(
        receipt,
        runId,
        sessionId,
        callId,
        toolName,
        rawArguments,
      );
      throw cancelToken!.cancelError!;
    }

    // 2. Capability check
    if (!_isToolAllowed(toolName)) {
      final receipt = ToolInvocationReceipt(
        runId: runId,
        callId: callId,
        invocationId: callId,
        toolName: toolName,
        arguments: rawArguments,
        status: InvocationStatus.failed,
        isError: true,
        result: 'Tool $toolName is not allowed in current capability scope',
        timestamp: DateTime.now(),
        backend: backend,
        durationMs: stopwatch.elapsedMilliseconds,
      );
      await _recordReceipt(
        receipt,
        runId,
        sessionId,
        callId,
        toolName,
        rawArguments,
      );
      return AgentToolResult(
        content: TextPart('Error: Tool $toolName is not allowed'),
        metadata: {'isError': true},
      );
    }

    // 3. Dispatch: serialize side-effecting calls, parallelize read-only
    final requiresLock = !isReadOnly(toolName);
    Completer<void>? lockCompleter;
    if (requiresLock) {
      final prevLock = _runLocks[runId] ?? Future.value();
      lockCompleter = Completer<void>();
      _runLocks[runId] = lockCompleter.future;
      await prevLock;
    }

    try {
      // Re-check cancellation after lock acquisition
      if (cancelToken?.isCancelled ?? false) {
        final receipt = ToolInvocationReceipt(
          runId: runId,
          callId: callId,
          invocationId: callId,
          toolName: toolName,
          arguments: rawArguments,
          status: InvocationStatus.cancelled,
          isError: true,
          result: 'Cancelled before dispatch',
          timestamp: DateTime.now(),
          backend: backend,
          durationMs: stopwatch.elapsedMilliseconds,
        );
        await _recordReceipt(
          receipt,
          runId,
          sessionId,
          callId,
          toolName,
          rawArguments,
        );
        throw cancelToken!.cancelError!;
      }

      onEvent?.call(
        ToolCallStartedEvent(
          runId: runId,
          sessionId: sessionId,
          callId: callId,
          toolName: toolName,
          arguments: rawArguments,
        ),
      );

      // Execute through registered backend. HTTP calls made by the backend
      // are captured with this run/tool-call context.
      bool isError = false;
      final dynamic rawResult = await LogContext.runZoned(
        LogContext(conversationId: sessionId, runId: runId, toolCallId: callId),
        () async {
          if (_shellService != null && _shellService.handlesTool(toolName)) {
            backend = 'shell';
            return await _shellService.executeTool(
              toolName: toolName,
              arguments: arguments,
              runId: runId,
              sessionId: sessionId,
              cancelToken: cancelToken,
            );
          } else if (_subAgentSupervisor != null &&
              _subAgentSupervisor.handlesTool(toolName)) {
            backend = 'sub_agent';
            return await _subAgentSupervisor.executeTool(
              toolName: toolName,
              arguments: arguments,
              parentRunId: runId,
              sessionId: sessionId,
              cancelToken: cancelToken,
            );
          } else if (_memoryProvider != null &&
              _memoryProvider.handlesTool(toolName)) {
            backend = 'memory';
            return await _memoryProvider.executeTool(
              toolName: toolName,
              arguments: arguments,
              sessionId: sessionId,
            );
          } else if (_skillRegistry != null &&
              _skillRegistry.handlesTool(toolName)) {
            backend = 'skill';
            return await _skillRegistry.executeTool(
              toolName: toolName,
              arguments: arguments,
            );
          } else if (_toolExecutor != null) {
            backend = 'tool_executor';
            return await _toolExecutor.execute(toolName, arguments);
          } else {
            isError = true;
            return {'error': 'No executor available for tool: $toolName'};
          }
        },
      );

      if (rawResult is Map && rawResult['error'] != null) {
        isError = true;
      }

      final resultString = rawResult is String
          ? rawResult
          : jsonEncode(rawResult);
      final receipt = ToolInvocationReceipt(
        runId: runId,
        callId: callId,
        invocationId: callId,
        toolName: toolName,
        arguments: rawArguments,
        status: isError ? InvocationStatus.failed : InvocationStatus.succeeded,
        isError: isError,
        result: rawResult,
        timestamp: DateTime.now(),
        backend: backend,
        durationMs: stopwatch.elapsedMilliseconds,
      );

      await _recordReceipt(
        receipt,
        runId,
        sessionId,
        callId,
        toolName,
        rawArguments,
      );

      return AgentToolResult(
        content: TextPart(resultString),
        metadata: {
          'toolCallId': callId,
          'toolName': toolName,
          'isError': isError,
        },
      );
    } catch (e, st) {
      final isCancel = cancelToken?.isCancelled ?? false;
      final receipt = ToolInvocationReceipt(
        runId: runId,
        callId: callId,
        invocationId: callId,
        toolName: toolName,
        arguments: rawArguments,
        status: isCancel ? InvocationStatus.cancelled : InvocationStatus.failed,
        isError: true,
        result: e.toString(),
        timestamp: DateTime.now(),
        errorType: e.runtimeType.toString(),
        stackTrace: st.toString(),
        backend: backend,
        durationMs: stopwatch.elapsedMilliseconds,
      );
      await _recordReceipt(
        receipt,
        runId,
        sessionId,
        callId,
        toolName,
        rawArguments,
      );
      if (isCancel) rethrow;
      return AgentToolResult(
        content: TextPart('Tool execution failed: $e'),
        metadata: {'isError': true},
      );
    } finally {
      lockCompleter?.complete();
    }
  }

  Future<void> _recordReceipt(
    ToolInvocationReceipt receipt,
    String runId,
    String sessionId,
    String callId,
    String toolName,
    String arguments,
  ) async {
    final completer = Completer<void>();
    onEvent?.call(
      ToolCallCompletedEvent(
        runId: runId,
        sessionId: sessionId,
        callId: callId,
        toolName: toolName,
        arguments: arguments,
        receipt: receipt,
        acknowledgement: completer,
      ),
    );

    if (_awaitAcknowledgements) {
      try {
        await completer.future;
      } catch (_) {
        // Tool errors become tool results, so a rejection cannot fail the run
        // from here; the acknowledging side cancels the run instead.
      }
    }

    if (onReceipt != null) {
      await onReceipt!(receipt);
    }
  }

  void cleanupRun(String runId) {
    _runLocks.remove(runId);
    _preparedCalls.removeWhere((k, _) => k.startsWith('$runId:'));
    _shellService?.cleanupRun(runId);
    _subAgentSupervisor?.cleanupRun(runId);
  }
}
