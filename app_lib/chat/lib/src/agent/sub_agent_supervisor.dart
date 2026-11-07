import 'dart:async';

import 'package:dio/dio.dart';

import '../services/tool_executor.dart';

/// Atomic shared budget for an entire agent execution tree.
class TreeBudget {
  TreeBudget({
    this.maxDepth = 3,
    this.maxConcurrency = 4,
    this.maxTurns = 50,
    this.maxToolCalls = 100,
  });

  final int maxDepth;
  final int maxConcurrency;
  final int maxTurns;
  final int maxToolCalls;

  int _activeConcurrency = 0;
  int _totalTurns = 0;
  int _totalToolCalls = 0;

  int get activeConcurrency => _activeConcurrency;
  int get totalTurns => _totalTurns;
  int get totalToolCalls => _totalToolCalls;

  /// Atomically checks and reserves worker execution slot.
  bool tryAcquireWorker(int depth) {
    if (depth >= maxDepth) return false;
    if (_activeConcurrency >= maxConcurrency) return false;
    _activeConcurrency++;
    return true;
  }

  void releaseWorker() {
    if (_activeConcurrency > 0) {
      _activeConcurrency--;
    }
  }

  /// Atomically increments and verifies model turns.
  bool recordTurn() {
    if (_totalTurns >= maxTurns) return false;
    _totalTurns++;
    return true;
  }

  /// Atomically increments and verifies tool calls.
  bool recordToolCall() {
    if (_totalToolCalls >= maxToolCalls) return false;
    _totalToolCalls++;
    return true;
  }
}

/// Represents a managed sub-agent worker task.
class SubAgentTask {
  SubAgentTask({
    required this.taskId,
    required this.parentRunId,
    required this.childRunId,
    required this.workerName,
    required this.goal,
    this.contextSnippet,
    this.allowedTools,
    required this.cancelToken,
    required this.createdAt,
  }) : completer = Completer<dynamic>();

  final String taskId;
  final String parentRunId;
  final String childRunId;
  final String workerName;
  final String goal;
  final String? contextSnippet;
  final Set<String>? allowedTools;
  final CancelToken cancelToken;
  final DateTime createdAt;
  final Completer<dynamic> completer;

  String status = 'spawned';
  dynamic result;
  String? error;
  DateTime? completedAt;

  bool get isCompleted => completer.isCompleted;

  Map<String, dynamic> toSummary() => {
    'taskId': taskId,
    'parentRunId': parentRunId,
    'childRunId': childRunId,
    'workerName': workerName,
    'status': status,
    'isCompleted': isCompleted,
    if (result != null) 'result': result,
    if (error != null) 'error': error,
    'createdAt': createdAt.toIso8601String(),
    if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
  };
}

/// Runner function signature to execute a child agent run.
typedef ChildAgentRunner =
    Future<dynamic> Function({
      required String childRunId,
      required String role,
      required String prompt,
      required Set<String>? allowedTools,
      required CancelToken cancelToken,
      required TreeBudget budget,
      required int depth,
    });

/// Supervisor managing named sub-agent workers with shared budgets and tree hierarchy.
class AgentSupervisor {
  AgentSupervisor({ChildAgentRunner? childRunner, TreeBudget? budget})
    : _childRunner = childRunner,
      _budget = budget ?? TreeBudget();

  final ChildAgentRunner? _childRunner;
  final TreeBudget _budget;

  /// Active tasks mapped by taskId.
  final Map<String, SubAgentTask> _tasks = {};

  /// Task IDs grouped by parentRunId.
  final Map<String, List<String>> _tasksByParentRunId = {};

  TreeBudget get budget => _budget;

  static const _spawnTool = 'spawn_agent';
  static const _waitTool = 'wait_agent';
  static const _cancelTool = 'cancel_agent';

  bool handlesTool(String toolName) =>
      {_spawnTool, _waitTool, _cancelTool}.contains(toolName);

  List<ChatToolDefinition> get toolDefinitions => [
    const ChatToolDefinition(
      name: _spawnTool,
      description:
          'Spawn a named sub-agent worker with a specific goal, context, and capability subset.',
      parameters: {
        'type': 'object',
        'properties': {
          'name': {
            'type': 'string',
            'description':
                'Worker role or type (e.g., researcher, coder, reviewer).',
          },
          'goal': {
            'type': 'string',
            'description':
                'The detailed objective or prompt for the sub-agent.',
          },
          'context': {
            'type': 'string',
            'description': 'Optional background or context snippet.',
          },
          'tools': {
            'type': 'array',
            'items': {'type': 'string'},
            'description':
                'Optional list of allowed tool names for the sub-agent.',
          },
        },
        'required': ['name', 'goal'],
      },
    ),
    const ChatToolDefinition(
      name: _waitTool,
      description:
          'Wait for a spawned sub-agent worker to finish and retrieve its result.',
      parameters: {
        'type': 'object',
        'properties': {
          'taskId': {
            'type': 'string',
            'description': 'The taskId of the spawned sub-agent.',
          },
          'timeout': {
            'type': 'integer',
            'description':
                'Milliseconds to wait before returning status (default 30000ms).',
          },
        },
        'required': ['taskId'],
      },
    ),
    const ChatToolDefinition(
      name: _cancelTool,
      description: 'Cancel a running sub-agent worker.',
      parameters: {
        'type': 'object',
        'properties': {
          'taskId': {
            'type': 'string',
            'description': 'The taskId of the sub-agent to cancel.',
          },
        },
        'required': ['taskId'],
      },
    ),
  ];

  Future<dynamic> executeTool({
    required String toolName,
    required Map<String, dynamic> arguments,
    required String parentRunId,
    required String sessionId,
    CancelToken? cancelToken,
    int depth = 1,
  }) async {
    switch (toolName) {
      case _spawnTool:
        return _spawnAgent(arguments, parentRunId, cancelToken, depth);
      case _waitTool:
        return _waitAgent(arguments, parentRunId, cancelToken);
      case _cancelTool:
        return _cancelAgent(arguments, parentRunId);
      default:
        return {'error': 'Unknown sub-agent tool: $toolName'};
    }
  }

  Future<dynamic> _spawnAgent(
    Map<String, dynamic> args,
    String parentRunId,
    CancelToken? parentCancelToken,
    int depth,
  ) async {
    final name = args['name'] as String;
    final goal = args['goal'] as String;
    final context = args['context'] as String?;
    final toolsList = (args['tools'] as List?)?.cast<String>();
    final allowedTools = toolsList != null ? Set<String>.from(toolsList) : null;

    if (!_budget.tryAcquireWorker(depth)) {
      return {
        'error':
            'Tree budget exceeded: cannot spawn worker. '
            'Active workers: ${_budget.activeConcurrency}/${_budget.maxConcurrency}, '
            'Depth: $depth/${_budget.maxDepth}',
        'status': 'budget_exceeded',
      };
    }

    final taskId = 'sub_${DateTime.now().microsecondsSinceEpoch}';
    final childRunId = 'run_$taskId';
    final childCancelToken = CancelToken();

    final task = SubAgentTask(
      taskId: taskId,
      parentRunId: parentRunId,
      childRunId: childRunId,
      workerName: name,
      goal: goal,
      contextSnippet: context,
      allowedTools: allowedTools,
      cancelToken: childCancelToken,
      createdAt: DateTime.now(),
    );

    // Propagate parent cancellation to child
    if (parentCancelToken != null) {
      if (parentCancelToken.isCancelled) {
        childCancelToken.cancel(
          parentCancelToken.cancelError ?? 'Parent run already cancelled',
        );
      } else {
        parentCancelToken.whenCancel.then((_) {
          if (!childCancelToken.isCancelled) {
            childCancelToken.cancel('Parent run cancelled');
          }
        });
      }
    }

    childCancelToken.whenCancel.then((_) {
      if (task.status == 'running' || task.status == 'spawned') {
        task.status = 'cancelled';
      }
    });

    _tasks[taskId] = task;
    _tasksByParentRunId.putIfAbsent(parentRunId, () => []).add(taskId);

    // Launch worker asynchronously
    unawaited(_runWorker(task, depth));

    return {
      'taskId': taskId,
      'childRunId': childRunId,
      'status': 'spawned',
      'worker': name,
    };
  }

  Future<void> _runWorker(SubAgentTask task, int depth) async {
    task.status = 'running';
    final runner = _childRunner;
    try {
      if (runner != null) {
        final snippet = task.contextSnippet;
        final combinedPrompt = snippet != null && snippet.isNotEmpty
            ? '$snippet\n\nTask: ${task.goal}'
            : task.goal;

        final res = await runner(
          childRunId: task.childRunId,
          role: task.workerName,
          prompt: combinedPrompt,
          allowedTools: task.allowedTools,
          cancelToken: task.cancelToken,
          budget: _budget,
          depth: depth + 1,
        );

        task.result = res;
        task.status = 'succeeded';
        if (!task.completer.isCompleted) {
          task.completer.complete(res);
        }
      } else {
        // Fallback simulated execution if runner not injected
        final res = 'Worker ${task.workerName} finished goal: ${task.goal}';
        task.result = res;
        task.status = 'succeeded';
        if (!task.completer.isCompleted) {
          task.completer.complete(res);
        }
      }
    } catch (e, st) {
      if (task.cancelToken.isCancelled) {
        task.status = 'cancelled';
        task.error = 'Worker cancelled: $e';
      } else {
        task.status = 'failed';
        task.error = e.toString();
      }
      if (!task.completer.isCompleted) {
        task.completer.completeError(e, st);
      }
    } finally {
      task.completedAt = DateTime.now();
      _budget.releaseWorker();
    }
  }

  Future<dynamic> _waitAgent(
    Map<String, dynamic> args,
    String parentRunId,
    CancelToken? cancelToken,
  ) async {
    final taskId = args['taskId'] as String;
    final timeoutMs = (args['timeout'] as num?)?.toInt() ?? 30000;

    final task = _tasks[taskId];
    if (task == null) {
      return {'error': 'Sub-agent task $taskId not found'};
    }
    if (task.parentRunId != parentRunId) {
      return {'error': 'Sub-agent task $taskId belongs to another parent run'};
    }

    if (task.isCompleted) {
      return task.toSummary();
    }

    try {
      final waitFuture = task.completer.future;
      final timeoutFuture = Future.delayed(Duration(milliseconds: timeoutMs));
      await Future.any([waitFuture, timeoutFuture]);
    } catch (_) {
      // Completed with error handled by toSummary
    }

    return task.toSummary();
  }

  Future<dynamic> _cancelAgent(
    Map<String, dynamic> args,
    String parentRunId,
  ) async {
    final taskId = args['taskId'] as String;
    final task = _tasks[taskId];
    if (task == null) {
      return {'error': 'Sub-agent task $taskId not found'};
    }
    if (task.parentRunId != parentRunId) {
      return {'error': 'Sub-agent task $taskId belongs to another parent run'};
    }

    if (!task.cancelToken.isCancelled) {
      task.cancelToken.cancel('Cancelled by parent request');
    }
    task.status = 'cancelled';
    return {'taskId': taskId, 'status': 'cancelled'};
  }

  /// Cancels and cleans up all sub-agents spawned by the parent run.
  void cleanupRun(String parentRunId) {
    final taskIds = _tasksByParentRunId.remove(parentRunId);
    if (taskIds != null) {
      for (final id in taskIds) {
        final task = _tasks.remove(id);
        if (task != null && !task.cancelToken.isCancelled) {
          task.cancelToken.cancel('Parent run finished or cleaned up');
        }
      }
    }
  }
}
