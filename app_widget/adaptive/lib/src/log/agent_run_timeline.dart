import 'dart:convert';

import 'package:app_duckdb/app_duckdb.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';

import 'api_exchange_detail.dart';
import 'duckdb_log_viewer.dart';
import 'log_detail_sheet.dart';

/// Ordered timeline of one agent run's events. Model turns link to the LLM
/// exchanges of the same `(run_id, turn)` and tool calls to the exchanges
/// tagged with their `tool_call_id`; each link opens [ApiExchangeDetail].
class AgentRunTimeline extends StatefulWidget {
  const AgentRunTimeline({super.key, required this.runId, this.duckDb});

  final String runId;
  final AppDuckDb? duckDb;

  /// Looks up the `run_id` of the `agent_events` row [id].
  static Future<String?> runIdOf(AppDuckDb duckDb, String id) async {
    final rows = jsonDecode(
      await duckDb.queryJson(
        'SELECT run_id FROM agent_events '
        "WHERE id = '${LogQueryBuilder.escapeLiteral(id)}';",
      ),
    );
    if (rows is List && rows.isNotEmpty && rows.first is Map) {
      return (rows.first as Map)['run_id'] as String?;
    }
    return null;
  }

  static Future<void> show(
    BuildContext context, {
    required AppDuckDb duckDb,
    required String runId,
  }) =>
      LogDetailSheet.showModal(
        context,
        AgentRunTimeline(runId: runId, duckDb: duckDb),
      );

  @override
  State<AgentRunTimeline> createState() => _AgentRunTimelineState();
}

typedef _Row = Map<String, dynamic>;

class _AgentRunTimelineState extends State<AgentRunTimeline> {
  late final Future<({List<_Row> events, List<_Row> exchanges})> _data =
      _load();

  AppDuckDb get _duckDb => widget.duckDb ?? AppDuckDb.instance;

  Future<({List<_Row> events, List<_Row> exchanges})> _load() async {
    final runId = LogQueryBuilder.escapeLiteral(widget.runId);
    List<_Row> rows(String json) {
      final decoded = jsonDecode(json);
      return decoded is List ? decoded.whereType<_Row>().toList() : [];
    }

    final events = rows(
      await _duckDb.queryJson(
        "SELECT * FROM agent_events WHERE run_id = '$runId' "
        'ORDER BY timestamp_us ASC;',
      ),
    );
    final exchanges = rows(
      await _duckDb.queryJson(
        'SELECT id, timestamp_us, request_id, record_type, method, host, '
        'path, status, has_error, turn, tool_call_id FROM api_exchanges '
        "WHERE run_id = '$runId' ORDER BY timestamp_us ASC;",
      ),
    );
    return (events: events, exchanges: exchanges);
  }

  /// One entry per request_id (a streamed call has request + response rows);
  /// the last row carries the final status.
  static List<_Row> _byRequest(List<_Row> rows) {
    final out = <String, _Row>{};
    for (final r in rows) {
      final key = '${r['request_id'] ?? r['id']}';
      final first = out[key];
      out[key] = first == null
          ? r
          : {
              ...first,
              'status': r['status'] ?? first['status'],
              'has_error': r['has_error'] == true || first['has_error'] == true,
            };
    }
    return out.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.logAgentRunTitle,
                        style: theme.textTheme.titleMedium),
                    SelectableText(
                      widget.runId,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
              if (Navigator.of(context).canPop())
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => Navigator.of(context).pop(),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: FutureBuilder(
            future: _data,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(l10n.logDetailLoadFailed('${snapshot.error}')),
                );
              }
              final data = snapshot.data;
              if (data == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (data.events.isEmpty && data.exchanges.isEmpty) {
                return Center(child: Text(l10n.logAgentRunEmpty));
              }
              return _buildTimeline(context, data.events, data.exchanges);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(
    BuildContext context,
    List<_Row> events,
    List<_Row> exchangeRows,
  ) {
    final exchanges = _byRequest(exchangeRows);
    final linked = <Object?>{};

    List<_Row> linksFor(_Row event) {
      final type = event['event_type'];
      final List<_Row> links;
      if (type == 'model_turn_started' && event['turn'] != null) {
        links = exchanges
            .where(
                (x) => x['turn'] == event['turn'] && x['tool_call_id'] == null)
            .toList();
      } else if (type == 'tool_call_completed' &&
          event['tool_call_id'] != null) {
        links = exchanges
            .where((x) => x['tool_call_id'] == event['tool_call_id'])
            .toList();
      } else {
        links = const [];
      }
      linked.addAll(links.map((x) => x['id']));
      return links;
    }

    final tiles = <Widget>[
      for (final event in events) _eventTile(context, event, linksFor(event)),
    ];
    final orphans = exchanges.where((x) => !linked.contains(x['id'])).toList();
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ...tiles,
        if (orphans.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _links(context, orphans),
          ),
      ],
    );
  }

  Widget _eventTile(BuildContext context, _Row event, List<_Row> links) {
    final colors = Theme.of(context).colorScheme;
    final type = '${event['event_type'] ?? ''}';
    final isError = event['is_error'] == true;
    final ts = DateTime.fromMicrosecondsSinceEpoch(
      (event['timestamp_us'] as num?)?.toInt() ?? 0,
    ).toLocal();
    final time = ts.toString().split(' ').last;
    final duration = event['duration_ms'];
    final icon = switch (type) {
      'agent_run_started' => Icons.play_arrow,
      'agent_run_completed' => Icons.check_circle_outline,
      'agent_run_failed' => Icons.error_outline,
      'agent_run_cancelled' => Icons.cancel_outlined,
      'model_turn_started' ||
      'model_turn_completed' =>
        Icons.smart_toy_outlined,
      'sub_agent_started' ||
      'sub_agent_finished' =>
        Icons.account_tree_outlined,
      _ when type.startsWith('tool_call') => Icons.build_outlined,
      _ => Icons.circle_outlined,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          dense: true,
          leading: Icon(icon, color: isError ? colors.error : colors.primary),
          title: Text(
            '${event['summary'] ?? type}',
            style: TextStyle(color: isError ? colors.error : null),
          ),
          subtitle: Text(
            [
              time,
              type,
              if (event['backend'] != null) '${event['backend']}',
              if (duration != null) '$duration ms',
            ].join(' · '),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
          onTap: () => LogDetailSheet.show(
            context,
            LogRecordItem.fromMap(event, defaultType: 'agent'),
          ),
        ),
        if (links.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(72, 0, 16, 8),
            child: _links(context, links),
          ),
      ],
    );
  }

  Widget _links(BuildContext context, List<_Row> exchanges) {
    final colors = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final x in exchanges)
          ActionChip(
            avatar: Icon(
              Icons.http,
              size: 16,
              color: x['has_error'] == true ||
                      ((x['status'] as num?)?.toInt() ?? 0) >= 400
                  ? colors.error
                  : colors.primary,
            ),
            label: Text(
              '${x['method'] ?? ''} ${x['host'] ?? ''}${x['path'] ?? ''}'
              ' → ${x['status'] ?? 'ERR'}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
            onPressed: () => ApiExchangeDetail.show(
              context,
              duckDb: _duckDb,
              id: '${x['id']}',
            ),
          ),
      ],
    );
  }
}

/// Agent-tab list: one card per agent run, built from the run summary rows
/// of [AppDuckDb.queryAgentRuns] (see [pageQuery]); tapping a card opens the
/// run's [AgentRunTimeline].
class AgentRunGroupList extends StatelessWidget {
  const AgentRunGroupList({super.key, required this.items, this.duckDb});

  /// Run items produced by [runItem].
  final List<LogRecordItem> items;
  final AppDuckDb? duckDb;

  /// Maps a run summary row to a list item: id = `run_id`, timestamp and
  /// message both from the run's latest event.
  static LogRecordItem runItem(Map<String, dynamic> row) => LogRecordItem(
        id: '${row['run_id']}',
        timestamp: DateTime.fromMicrosecondsSinceEpoch(
          (row['last_us'] as num?)?.toInt() ?? 0,
        ),
        logType: 'agent',
        level: row['has_error'] == true ? LogLevel.error : LogLevel.info,
        message: '${row['last_summary'] ?? ''}',
        rawFields: row,
      );

  /// A [LogPageQuery] paging over agent runs instead of events.
  static LogPageQuery pageQuery(AppDuckDb? duckDb) =>
      (filter, limit, offset) async {
        final db = duckDb ?? AppDuckDb.instance;
        final total = await db.countAgentRuns(filter: filter);
        final rows = await db.queryAgentRuns(
          filter: filter,
          limit: limit,
          offset: offset,
        );
        return (total: total, items: rows.map(runItem).toList());
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final db = duckDb ?? AppDuckDb.instance;

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        for (final run in items)
          Card(
            child: ListTile(
              leading: Icon(
                Icons.smart_toy_outlined,
                color:
                    run.level == LogLevel.error ? colors.error : colors.primary,
              ),
              title: Text(
                l10n.logAgentConversation(
                  '${run.rawFields['conversation_id'] ?? '-'}',
                ),
              ),
              subtitle: Text(
                [
                  run.timestamp.toLocal().toString().split('.').first,
                  l10n.logAgentEventCount(
                    (run.rawFields['event_count'] as num?)?.toInt() ?? 0,
                  ),
                  run.message,
                  run.id,
                ].join(' · '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  AgentRunTimeline.show(context, duckDb: db, runId: run.id),
            ),
          ),
      ],
    );
  }
}
