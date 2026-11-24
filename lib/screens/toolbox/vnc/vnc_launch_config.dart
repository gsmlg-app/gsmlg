import 'package:app_vnc/app_vnc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Navigation payload passed to [VncSessionScreen] via GoRouter `extra`.
@immutable
class VncLaunchConfig extends Equatable {
  const VncLaunchConfig({
    required this.title,
    required this.config,
    this.savedHostId,
  });

  final String title;
  final VncConnectionConfig config;
  final int? savedHostId;

  @override
  List<Object?> get props => [title, config, savedHostId];
}
