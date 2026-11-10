import 'dart:convert';

import 'package:app_duckdb/app_duckdb.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'log_detail_sheet.dart';

/// Full view of one captured API exchange in the proxy-dump record format:
/// request and response sections with headers, pretty-printed JSON bodies,
/// raw text / SSE bodies, and a "Copy JSONL" action.
class ApiExchangeDetail extends StatelessWidget {
  const ApiExchangeDetail({super.key, required this.record, this.jsonl});

  /// A decoded `record_json` (or several merged with [merge]).
  final Map<String, Object?> record;

  /// Text copied by "Copy JSONL"; defaults to [record] encoded on one line.
  final String? jsonl;

  /// Merges the records sharing one `request_id` (a streamed call stores a
  /// `request` and a `response` record) into a single exchange view.
  static Map<String, Object?> merge(List<Map<String, Object?>> records) {
    final merged = <String, Object?>{};
    for (final r in records) {
      for (final e in r.entries) {
        if (e.value != null) merged[e.key] = e.value;
      }
    }
    return merged;
  }

  /// Loads every record sharing the `request_id` of the `api_exchanges` row
  /// [id], oldest first, decoded from `record_json`.
  static Future<List<Map<String, Object?>>> loadRecords(
    LogStore logStore,
    String id,
  ) async {
    final safeId = LogQueryBuilder.escapeLiteral(id);
    final json = await logStore.queryJson(
      'SELECT record_json FROM api_exchanges WHERE request_id = '
      "(SELECT request_id FROM api_exchanges WHERE id = '$safeId') "
      'ORDER BY timestamp_us ASC;',
    );
    final rows = jsonDecode(json);
    if (rows is! List) return const [];
    return [
      for (final row in rows.whereType<Map<String, dynamic>>())
        if (_decode(row['record_json']) case final Map<String, Object?> m) m,
    ];
  }

  static Map<String, Object?>? _decode(Object? value) {
    if (value is Map<String, Object?>) return value;
    if (value is! String) return null;
    try {
      final decoded = jsonDecode(value);
      return decoded is Map<String, Object?> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  /// Loads the exchange for row [id] and shows it in a dialog / sheet.
  static Future<void> show(
    BuildContext context, {
    required LogStore logStore,
    required String id,
  }) =>
      LogDetailSheet.showModal(
        context,
        FutureBuilder<List<Map<String, Object?>>>(
          future: loadRecords(logStore, id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  context.l10n.logDetailLoadFailed('${snapshot.error}'),
                ),
              );
            }
            final records = snapshot.data;
            if (records == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return ApiExchangeDetail(
              record: merge(records),
              jsonl: records.map(jsonEncode).join('\n'),
            );
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final request = _map(record['request']);
    final response = _map(record['response']);
    final error = _map(record['error']);
    final status = response?['status'];
    final title = [
      request?['method'],
      '${request?['host'] ?? ''}${request?['uri'] ?? ''}',
    ].where((e) => e != null && '$e'.isNotEmpty).join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.copy, size: 14),
                label: Text(l10n.logApiCopyJsonl),
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: jsonl ?? jsonEncode(record)),
                  );
                  ScaffoldMessenger.maybeOf(
                    context,
                  )?.showSnackBar(SnackBar(content: Text(l10n.logApiCopied)));
                },
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final chip in [
                if (status != null) 'HTTP $status',
                if (record['duration_ms'] != null)
                  '${record['duration_ms']} ms',
                if (record['category'] != null) '${record['category']}',
                if (record['ts'] != null) '${record['ts']}',
                if (record['aborted'] == true) l10n.logApiAborted,
              ])
                Chip(label: Text(chip), visualDensity: VisualDensity.compact),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              if (error != null) ...[
                _sectionTitle(context, l10n.logApiError, color: colors.error),
                _codeBlock(
                  context,
                  [
                    '${error['type'] ?? ''}: ${error['message'] ?? ''}',
                    if (error['stack_trace'] != null) '${error['stack_trace']}',
                  ].join('\n\n'),
                  color: colors.error,
                ),
                const SizedBox(height: 16),
              ],
              _sectionTitle(context, l10n.logApiRequest),
              if (request != null) ..._message(context, request),
              const SizedBox(height: 16),
              _sectionTitle(context, l10n.logApiResponse),
              if (response != null)
                ..._message(context, response)
              else
                Text(l10n.logApiNoResponse),
            ],
          ),
        ),
      ],
    );
  }

  static Map<String, Object?>? _map(Object? v) =>
      v is Map ? v.cast<String, Object?>() : null;

  List<Widget> _message(BuildContext context, Map<String, Object?> msg) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final headers = _map(msg['headers']) ?? const {};
    final encoding = msg['body_encoding'];
    final body = msg['body'];
    final bodyText = switch (encoding) {
      'json' => const JsonEncoder.withIndent('  ').convert(body),
      _ => body?.toString(),
    };

    return [
      Text(
        l10n.logApiHeaders,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 4),
      Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(flex: 1),
          1: FlexColumnWidth(2),
        },
        children: [
          for (final h in headers.entries)
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12, bottom: 2),
                  child: SelectableText(
                    h.key,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SelectableText(
                  h.value is List ? (h.value as List).join(', ') : '${h.value}',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        [
          l10n.logApiBody,
          if (msg['content_type'] != null) '${msg['content_type']}',
          if (encoding == 'base64') l10n.logApiBodyBase64,
          if (msg['body_truncated'] == true) l10n.logApiBodyTruncated,
        ].join(' · '),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 4),
      if (bodyText == null || bodyText.isEmpty)
        Text(l10n.logApiNoBody)
      else
        _codeBlock(context, bodyText),
    ];
  }

  Widget _sectionTitle(BuildContext context, String text, {Color? color}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      );

  Widget _codeBlock(BuildContext context, String text, {Color? color}) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: SelectableText(
        text,
        style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: color),
      ),
    );
  }
}
