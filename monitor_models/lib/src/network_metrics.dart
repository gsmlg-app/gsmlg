import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monitor_models/src/protocol.dart';

@immutable
final class NetworkMetrics extends Equatable {
  const NetworkMetrics({
    required this.interface_,
    required this.txBytesPerSec,
    required this.rxBytesPerSec,
  });

  final String interface_;
  final int txBytesPerSec;
  final int rxBytesPerSec;

  factory NetworkMetrics.fromJson(Map<String, dynamic> json) => NetworkMetrics(
    interface_: json[Protocol.interface_] as String,
    txBytesPerSec: json[Protocol.txBytesPerSec] as int,
    rxBytesPerSec: json[Protocol.rxBytesPerSec] as int,
  );

  Map<String, dynamic> toJson() => {
    Protocol.interface_: interface_,
    Protocol.txBytesPerSec: txBytesPerSec,
    Protocol.rxBytesPerSec: rxBytesPerSec,
  };

  @override
  List<Object?> get props => [interface_, txBytesPerSec, rxBytesPerSec];
}
