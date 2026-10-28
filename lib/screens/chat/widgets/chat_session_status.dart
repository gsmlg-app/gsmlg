import 'dart:async';

import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';

/// Live activity belongs to a session, independently of list selection.
class ChatSessionStatus extends StatefulWidget {
  const ChatSessionStatus({super.key, this.session, this.hasDraft = false});

  final ChatSessionState? session;
  final bool hasDraft;

  @override
  State<ChatSessionStatus> createState() => _ChatSessionStatusState();
}

class _ChatSessionStatusState extends State<ChatSessionStatus> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTimer();
  }

  @override
  void didUpdateWidget(covariant ChatSessionStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session?.status != widget.session?.status) _updateTimer();
  }

  void _updateTimer() {
    _timer?.cancel();
    if (widget.session?.status == ChatStatus.streaming) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final running = session?.status == ChatStatus.streaming;
    final label = switch (session?.status) {
      ChatStatus.streaming => 'Running',
      ChatStatus.queued =>
        'Queued${session?.queuePosition == null ? '' : ' · ${session!.queuePosition}'}',
      ChatStatus.error => 'Failed',
      ChatStatus.stopped => 'Stopped',
      _ => session?.hasUnreadResponse == true ? 'New reply' : null,
    };
    final elapsed = session?.startedAt == null
        ? null
        : DateTime.now().difference(session!.startedAt!);
    final duration = elapsed == null
        ? ''
        : '${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
    final color = session?.status == ChatStatus.error
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    if (label == null && !widget.hasDraft) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (running)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            ),
          if (label != null)
            Text(
              running ? '$label · $duration' : label,
              style: TextStyle(color: color, fontSize: 12),
            ),
          if (running && session?.currentActivity != null)
            Text(
              session!.currentActivity!,
              style: TextStyle(color: color, fontSize: 12),
            ),
          if (widget.hasDraft)
            Text(
              'Draft',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}
