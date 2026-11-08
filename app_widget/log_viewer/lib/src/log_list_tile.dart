import 'package:flutter/material.dart';
import 'package:log_models/log_models.dart';

/// A row widget for displaying a log entry in a list.
///
/// Shows rich structured HTTP method, status code, duration, endpoint/path,
/// and snippet preview when available, with visual indicators for selection
/// and error state.
class LogListTile extends StatelessWidget {
  const LogListTile({
    super.key,
    required this.rawLine,
    required this.index,
    this.record,
    this.isSelected = false,
    this.isError = false,
    this.onTap,
  });

  final String rawLine;
  final int index;
  final LogRecord? record;
  final bool isSelected;
  final bool isError;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final effectiveIsError = isError || (record?.isError ?? false);

    // High contrast adaptive card surface & border
    final (Color cardBg, Color cardBorder) = isSelected
        ? (
            isDark
                ? colorScheme.primaryContainer.withValues(alpha: 0.40)
                : colorScheme.primaryContainer.withValues(alpha: 0.50),
            colorScheme.primary,
          )
        : effectiveIsError
        ? (
            isDark ? const Color(0xFF2A1515) : const Color(0xFFFFF5F5),
            isDark ? const Color(0xFF991B1B) : const Color(0xFFFCA5A5),
          )
        : (
            isDark ? colorScheme.surfaceContainerHigh : Colors.white,
            isDark
                ? colorScheme.outlineVariant.withValues(alpha: 0.35)
                : const Color(0xFFCBD5E1),
          );

    // High contrast line number pill
    final (Color linePillBg, Color linePillText, Color linePillBorder) =
        isSelected
            ? (colorScheme.primary, colorScheme.onPrimary, colorScheme.primary)
            : effectiveIsError
            ? (const Color(0xFFEF4444), Colors.white, const Color(0xFFDC2626))
            : isDark
            ? (
                const Color(0xFF1E293B),
                const Color(0xFFF1F5F9),
                const Color(0xFF475569),
              )
            : (
                const Color(0xFFF1F5F9),
                const Color(0xFF1E293B),
                const Color(0xFFCBD5E1),
              );

    // Text colors with WCAG AAA contrast
    final titleColor = isSelected
        ? colorScheme.onPrimaryContainer
        : effectiveIsError
        ? (isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B))
        : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A));

    final snippetColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF475569);

    final metaColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    final method =
        record?.method ??
        (record?.response != null && record?.request == null ? 'RESP' : null);
    final statusCode = record?.statusCode;
    final durationMs = record?.durationMs;
    final timeStr = _extractTime(record?.ts);
    final displayTitle = _getDisplayTitle();
    final snippet = _getSnippet();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 88,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cardBorder,
                width: isSelected ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1.5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Line Number Pill
                Container(
                  width: 42,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: linePillBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: linePillBorder, width: 1),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontFamily: 'Menlo',
                      fontFamilyFallback: const [
                        'Cascadia Code',
                        'Consolas',
                        'Courier New',
                      ],
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: linePillText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 10),
                // Main Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Row 1: Badges + Timestamp
                      Row(
                        children: [
                          if (effectiveIsError)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.error_outline,
                                size: 15,
                                color: isDark
                                    ? const Color(0xFFF87171)
                                    : const Color(0xFFDC2626),
                                semanticLabel: 'Error',
                              ),
                            ),
                          if (method != null && method.isNotEmpty) ...[
                            _MethodBadge(method: method),
                            const SizedBox(width: 6),
                          ],
                          if (statusCode != null && statusCode > 0) ...[
                            _StatusBadge(statusCode: statusCode),
                            const SizedBox(width: 6),
                          ],
                          if (durationMs != null && durationMs > 0) ...[
                            Text(
                              '${durationMs.toStringAsFixed(0)}ms',
                              style: TextStyle(
                                fontFamily: 'Menlo',
                                fontFamilyFallback: const [
                                  'Cascadia Code',
                                  'Consolas',
                                  'Courier New',
                                ],
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: metaColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          const Spacer(),
                          if (timeStr.isNotEmpty)
                            Text(
                              timeStr,
                              style: TextStyle(
                                fontFamily: 'Menlo',
                                fontFamilyFallback: const [
                                  'Cascadia Code',
                                  'Consolas',
                                  'Courier New',
                                ],
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: metaColor,
                              ),
                            ),
                        ],
                      ),
                      // Row 2: Title
                      Text(
                        displayTitle,
                        style: TextStyle(
                          fontFamily: 'Menlo',
                          fontFamilyFallback: const [
                            'Cascadia Code',
                            'Consolas',
                            'Courier New',
                          ],
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Row 3: Snippet
                      if (snippet.isNotEmpty && snippet != displayTitle)
                        Text(
                          snippet,
                          style: TextStyle(
                            fontFamily: 'Menlo',
                            fontFamilyFallback: const [
                              'Cascadia Code',
                              'Consolas',
                              'Courier New',
                            ],
                            fontSize: 11,
                            color: snippetColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _extractTime(String? ts) {
    if (ts == null || ts.isEmpty) return '';
    try {
      final dt = DateTime.parse(ts).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      final s = dt.second.toString().padLeft(2, '0');
      return '$h:$m:$s';
    } catch (_) {
      if (ts.contains('T')) {
        final timePart = ts.split('T').last;
        return timePart.split('.').first;
      }
      return ts.length > 8 ? ts.substring(0, 8) : ts;
    }
  }

  String _getDisplayTitle() {
    final path = record?.path;
    if (path != null && path.isNotEmpty) return path;

    final msg = record?.message;
    if (msg != null && msg.isNotEmpty) return msg;

    final req = record?.request;
    if (req != null) {
      if (req.uri.isNotEmpty) return req.uri;
      if (req.host.isNotEmpty) return req.host;
    }

    if (record?.response != null) {
      final status = record?.statusCode ?? record!.response!.status;
      final statusText = status > 0 ? '$status' : 'OK';
      final idShort = record!.requestId.isNotEmpty
          ? (record!.requestId.length > 8
              ? record!.requestId.substring(0, 8)
              : record!.requestId)
          : '';
      if (idShort.isNotEmpty) {
        return 'Response [$statusText] • req_$idShort';
      }
      return 'Response [$statusText]';
    }

    return _cleanSnippet(rawLine);
  }

  String _getSnippet() {
    final reqBody = record?.request?.body;
    if (reqBody != null && reqBody.trim().isNotEmpty) {
      return _cleanSnippet(reqBody);
    }

    final respBody = record?.response?.body;
    if (respBody != null && respBody.trim().isNotEmpty) {
      return _cleanSnippet(respBody);
    }

    return _cleanSnippet(rawLine);
  }

  static String _cleanSnippet(String text) {
    if (text.isEmpty) return '';
    // CRITICAL: Slice at most first 250 characters BEFORE running regex/trim!
    // Prevents running regex search across 200,000 characters on every frame.
    final sample = text.length > 250 ? text.substring(0, 250) : text;
    final trimmed = sample.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (trimmed.length > 140) {
      return '${trimmed.substring(0, 140)}...';
    }
    return trimmed;
  }
}

class _MethodBadge extends StatelessWidget {
  const _MethodBadge({required this.method});

  final String method;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final upper = method.toUpperCase();

    final (Color bg, Color text, Color border) = switch (upper) {
      'GET' => isDark
          ? (
              const Color(0xFF064E3B),
              const Color(0xFF6EE7B7),
              const Color(0xFF047857),
            )
          : (
              const Color(0xFFD1FAE5),
              const Color(0xFF047857),
              const Color(0xFFA7F3D0),
            ),
      'POST' => isDark
          ? (
              const Color(0xFF1E3A8A),
              const Color(0xFF93C5FD),
              const Color(0xFF1D4ED8),
            )
          : (
              const Color(0xFFDBEAFE),
              const Color(0xFF1D4ED8),
              const Color(0xFFBFDBFE),
            ),
      'PUT' || 'PATCH' => isDark
          ? (
              const Color(0xFF78350F),
              const Color(0xFFFCD34D),
              const Color(0xFFB45309),
            )
          : (
              const Color(0xFFFEF3C7),
              const Color(0xFFB45309),
              const Color(0xFFFDE68A),
            ),
      'DELETE' => isDark
          ? (
              const Color(0xFF7F1D1D),
              const Color(0xFFFCA5A5),
              const Color(0xFFB91C1C),
            )
          : (
              const Color(0xFFFEE2E2),
              const Color(0xFFB91C1C),
              const Color(0xFFFECACA),
            ),
      'RESP' || 'RESPONSE' => isDark
          ? (
              const Color(0xFF4C1D95),
              const Color(0xFFC4B5FD),
              const Color(0xFF6D28D9),
            )
          : (
              const Color(0xFFEDE9FE),
              const Color(0xFF6D28D9),
              const Color(0xFFDDD6FE),
            ),
      _ => isDark
          ? (
              const Color(0xFF1E293B),
              const Color(0xFF94A3B8),
              const Color(0xFF334155),
            )
          : (
              const Color(0xFFF1F5F9),
              const Color(0xFF475569),
              const Color(0xFFCBD5E1),
            ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        upper,
        style: TextStyle(
          fontFamily: 'Menlo',
          fontFamilyFallback: const [
            'Cascadia Code',
            'Consolas',
            'Courier New',
          ],
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: text,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.statusCode});

  final int statusCode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (Color bg, Color text, Color border) = switch (statusCode) {
      >= 200 && < 300 => isDark
          ? (
              const Color(0xFF14532D),
              const Color(0xFF4ADE80),
              const Color(0xFF166534),
            )
          : (
              const Color(0xFFDCFCE7),
              const Color(0xFF15803D),
              const Color(0xFF86EFAC),
            ),
      >= 300 && < 400 => isDark
          ? (
              const Color(0xFF0C4A6E),
              const Color(0xFF38BDF8),
              const Color(0xFF075985),
            )
          : (
              const Color(0xFFE0F2FE),
              const Color(0xFF0369A1),
              const Color(0xFFBAE6FD),
            ),
      >= 400 && < 500 => isDark
          ? (
              const Color(0xFF7C2D12),
              const Color(0xFFFB923C),
              const Color(0xFF9A3412),
            )
          : (
              const Color(0xFFFFEDD5),
              const Color(0xFFC2410C),
              const Color(0xFFFED7AA),
            ),
      _ => isDark
          ? (
              const Color(0xFF7F1D1D),
              const Color(0xFFF87171),
              const Color(0xFF991B1B),
            )
          : (
              const Color(0xFFFEE2E2),
              const Color(0xFFB91C1C),
              const Color(0xFFFECACA),
            ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        '$statusCode',
        style: TextStyle(
          fontFamily: 'Menlo',
          fontFamilyFallback: const [
            'Cascadia Code',
            'Consolas',
            'Courier New',
          ],
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: text,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

