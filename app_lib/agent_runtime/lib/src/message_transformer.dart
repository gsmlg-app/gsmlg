import 'message.dart';

/// Pure message transformations and provider-context projection, modeled after
/// `Sigma.Agent.MessageTransformer`.
///
/// Guarantees that provider requests and persisted histories never contain
/// orphaned `function_call_output` results or dangling unanswered `function_call`
/// entries.
final class MessageTransformer {
  const MessageTransformer._();

  /// Applies a sequence of pure message transforms.
  static List<LLMMessage> transformContext(
    List<LLMMessage> messages, {
    List<List<LLMMessage> Function(List<LLMMessage>)> transforms = const [],
  }) {
    var current = messages;
    for (final transform in transforms) {
      current = transform(current);
    }
    return current;
  }

  /// Ensures strict pairing between `ModelMessage.functionCalls` and
  /// immediately following `FunctionExecutionResultMessage` items:
  ///
  /// - Drops orphaned `FunctionExecutionResultMessage` entries whose `id` does
  ///   not match a `FunctionCall.id` in the immediately preceding `ModelMessage`.
  /// - Strips unanswered `FunctionCall`s from a `ModelMessage` that were never
  ///   matched by a following tool result (e.g., after a crash or cancel).
  /// - Merges consecutive `FunctionExecutionResultMessage`s belonging to the
  ///   same preceding `ModelMessage` into a single paired result message.
  static List<LLMMessage> sanitize(List<LLMMessage> raw) {
    final result = <LLMMessage>[];
    var i = 0;
    while (i < raw.length) {
      final msg = raw[i];
      if (msg is FunctionExecutionResultMessage) {
        // Orphaned tool result with no preceding assistant tool call.
        i++;
        continue;
      }
      if (msg is ModelMessage && msg.functionCalls.isNotEmpty) {
        final declaredIds = <String>{
          for (final fc in msg.functionCalls)
            if (fc.id.isNotEmpty) fc.id,
        };
        final matchedResults = <FunctionExecutionResult>[];
        final matchedIds = <String>{};
        var j = i + 1;
        while (j < raw.length && raw[j] is FunctionExecutionResultMessage) {
          final resMsg = raw[j] as FunctionExecutionResultMessage;
          for (final r in resMsg.results) {
            if (r.id.isNotEmpty &&
                declaredIds.contains(r.id) &&
                matchedIds.add(r.id)) {
              matchedResults.add(r);
            }
          }
          j++;
        }

        final pairedCalls = msg.functionCalls
            .where((fc) => matchedIds.contains(fc.id))
            .toList();

        if (pairedCalls.isNotEmpty) {
          result.add(msg.copyWith(functionCalls: pairedCalls));
          result.add(FunctionExecutionResultMessage(results: matchedResults));
        } else if ((msg.textOutput?.trim().isNotEmpty ?? false) ||
            (msg.thought?.trim().isNotEmpty ?? false)) {
          result.add(msg.copyWith(functionCalls: const []));
        }
        i = j;
        continue;
      }
      result.add(msg);
      i++;
    }
    return result;
  }

  /// Completes unresolved tool calls in provider context without mutating
  /// canonical session history (mirrors `Sigma.Agent.MessageTransformer.complete_tool_results/1`).
  ///
  /// Unlike [sanitize], this preserves unanswered tool calls and synthesizes an
  /// explicit error result noting that the execution outcome is unknown.
  static List<LLMMessage> completeToolResults(List<LLMMessage> messages) {
    final result = <LLMMessage>[];
    var pending = <FunctionCall>[];

    void flushPending() {
      if (pending.isEmpty) return;
      result.add(
        FunctionExecutionResultMessage(
          results: [
            for (final call in pending)
              FunctionExecutionResult(
                id: call.id,
                name: call.name,
                arguments: call.arguments,
                isError: true,
                content: const [
                  TextPart(
                    'No tool result was recorded; execution outcome is unknown.',
                  ),
                ],
              ),
          ],
        ),
      );
      pending = <FunctionCall>[];
    }

    for (final msg in messages) {
      if (msg is FunctionExecutionResultMessage) {
        if (pending.isEmpty) {
          // Drop orphaned tool results with no matching preceding call.
          continue;
        }
        final pendingIds = {for (final c in pending) c.id};
        final matched = [
          for (final r in msg.results)
            if (pendingIds.contains(r.id)) r,
        ];
        if (matched.isNotEmpty) {
          result.add(FunctionExecutionResultMessage(results: matched));
          final answered = {for (final r in matched) r.id};
          pending = pending.where((c) => !answered.contains(c.id)).toList();
        }
        continue;
      }

      flushPending();
      result.add(msg);
      if (msg is ModelMessage && msg.functionCalls.isNotEmpty) {
        pending = List<FunctionCall>.from(msg.functionCalls);
      }
    }

    flushPending();
    return result;
  }
}
