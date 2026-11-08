import 'dart:convert';

import 'theme_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'json_tree_view.dart';

/// A content-type-aware body renderer for HTTP request/response bodies.
///
/// Renders the body based on content type:
/// - `application/json` is parsed and rendered with [JsonTreeView] or raw formatted text
/// - `text/*` is displayed as monospaced text
/// - Base64-encoded bodies show a placeholder with byte count
/// - Truncated bodies display a warning indicator
class BodyViewer extends StatefulWidget {
  const BodyViewer({
    super.key,
    required this.body,
    this.contentType,
    this.bodyEncoding,
    this.bodyTruncated = false,
  });

  final String? body;
  final String? contentType;
  final String? bodyEncoding;
  final bool bodyTruncated;

  @override
  State<BodyViewer> createState() => _BodyViewerState();
}

class _BodyViewerState extends State<BodyViewer> {
  bool _showRawText = false;
  bool _forceShowFullText = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.body == null || widget.body!.isEmpty) {
      return _BodySurface(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            '(empty body)',
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final isJson =
        widget.contentType != null &&
        widget.contentType!.toLowerCase().contains('application/json');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BodyHeader(
          body: widget.body!,
          contentType: widget.contentType,
          isJson: isJson,
          showRawText: _showRawText,
          onToggleView: (showRaw) {
            setState(() {
              _showRawText = showRaw;
            });
          },
        ),
        const SizedBox(height: 8),
        _BodySurface(child: _buildBody(context, isJson)),
        if (widget.bodyTruncated)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _TruncatedBanner(),
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, bool isJson) {
    final theme = Theme.of(context);

    if (widget.bodyEncoding == 'base64') {
      final byteCount = _estimateBase64Bytes(widget.body!);
      return Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          '[base64 binary, $byteCount bytes]',
          style: theme.codeTextStyle(
            fontSize: 12.5,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    if (isJson) {
      try {
        final parsed = jsonDecode(widget.body!);
        if (!_showRawText) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: JsonTreeView(
              data: parsed,
              initiallyExpanded: false,
              maxInitialDepth: 1,
            ),
          );
        }
        final prettyJson =
            widget.body!.length < 150000
                ? const JsonEncoder.withIndent('  ').convert(parsed)
                : widget.body!;
        return _renderTextContent(context, prettyJson);
      } on FormatException {
        // Fall through to plain text rendering.
      }
    }

    return _renderTextContent(context, widget.body!);
  }

  Widget _renderTextContent(BuildContext context, String text) {
    final theme = Theme.of(context);
    const limit = 40000;
    final isTruncated = text.length > limit && !_forceShowFullText;
    final displayText = isTruncated ? text.substring(0, limit) : text;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SelectableText(
            displayText,
            style: theme.codeTextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (isTruncated) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Previewing 40 KB of ${(text.length / 1024).toStringAsFixed(1)} KB (fluid mode).',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _forceShowFullText = true),
                    child: const Text('Show full text'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  int _estimateBase64Bytes(String base64String) {
    final padding =
        base64String.endsWith('==')
            ? 2
            : base64String.endsWith('=')
            ? 1
            : 0;
    return (base64String.length * 3 ~/ 4) - padding;
  }
}

class _BodyHeader extends StatelessWidget {
  const _BodyHeader({
    required this.body,
    required this.contentType,
    required this.isJson,
    required this.showRawText,
    required this.onToggleView,
  });

  final String body;
  final String? contentType;
  final bool isJson;
  final bool showRawText;
  final void Function(bool showRaw) onToggleView;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizeKb = (body.length / 1024).toStringAsFixed(1);

    return Row(
      children: [
        if (contentType != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              contentType!.split(';').first,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(width: 8),
        Text(
          '$sizeKb KB',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        if (isJson) ...[
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: showRawText ? 'Tree View' : 'Raw Text',
            icon: Icon(
              showRawText ? Icons.account_tree_outlined : Icons.code,
              size: 18,
            ),
            onPressed: () => onToggleView(!showRawText),
          ),
          const SizedBox(width: 4),
        ],
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: 'Copy Body',
          icon: const Icon(Icons.copy, size: 18),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: body));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Body copied to clipboard'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _BodySurface extends StatelessWidget {
  const _BodySurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _TruncatedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColors = theme.statusColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: statusColors.warningContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColors.warning.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: statusColors.warning,
            semanticLabel: 'Warning',
          ),
          const SizedBox(width: 8),
          Text(
            'Body was truncated',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: statusColors.onWarningContainer,
            ),
          ),
        ],
      ),
    );
  }
}
