/// A device activity sample. Nullable measurements are unavailable or warming up.
class ActivitySnapshot {
  const ActivitySnapshot({
    required this.timestamp,
    required this.architecture,
    required this.model,
    required this.cpuBrand,
    required this.cpuUsage,
    this.cpuUserUsage,
    this.cpuSystemUsage,
    required this.cores,
    required this.memory,
    required this.disk,
    required this.network,
    required this.gpus,
    this.processCount,
    this.threadCount,
    this.readableProcessCount,
    this.threadCountComplete = false,
  });

  final DateTime timestamp;
  final String architecture;
  final String model;
  final String cpuBrand;
  final double? cpuUsage;
  final double? cpuUserUsage;
  final double? cpuSystemUsage;
  final List<ActivityCpuCore> cores;
  final ActivityMemory memory;
  final ActivityDisk disk;
  final ActivityNetwork network;
  final List<ActivityGpu> gpus;
  final int? processCount;
  final int? threadCount;
  final int? readableProcessCount;
  final bool threadCountComplete;

  /// Convert native cumulative counters, comparing only compatible samples.
  factory ActivitySnapshot.fromSamples(
    Map<String, dynamic> raw, {
    Map<String, dynamic>? previous,
  }) {
    final timestamp = _counter(raw['timestamp_ms']);
    if (timestamp == null) {
      throw const FormatException('Activity sample has no valid timestamp_ms');
    }
    final now = _counter(raw['monotonic_ms']);
    final before = _counter(previous?['monotonic_ms']);
    final elapsed = now != null && before != null && now > before
        ? (now - before) / 1000.0
        : null;
    final cores = _maps(raw['cores']);
    final oldCores = _maps(previous?['cores']);
    final ids = cores.map((core) => _counter(core['id'])).toList();
    final oldById = {for (final core in oldCores) core['id']: core};
    final comparable = elapsed != null &&
        ids.isNotEmpty &&
        ids.every((id) => id != null && id > 0) &&
        ids.toSet().length == ids.length &&
        oldCores.length == cores.length &&
        ids.every(oldById.containsKey);
    final deltas = cores
        .map((core) => comparable ? _cpuDelta(core, oldById[core['id']]) : null)
        .toList();
    final active = _sum(deltas.map((delta) => delta?.$1));
    final total = _sum(deltas.map((delta) => delta?.$2));

    return ActivitySnapshot(
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true),
      architecture: _text(raw['architecture']),
      model: _text(raw['model']),
      cpuBrand: _text(raw['cpu_brand']),
      cpuUsage: cores.isEmpty ? null : _percent(active, total),
      cpuUserUsage: cores.isEmpty
          ? null
          : _percent(_sum(deltas.map((delta) => delta?.$3)), total),
      cpuSystemUsage: cores.isEmpty
          ? null
          : _percent(_sum(deltas.map((delta) => delta?.$4)), total),
      cores: List.unmodifiable([
        for (var index = 0; index < cores.length; index++)
          ActivityCpuCore(
            id: _counter(cores[index]['id']) ?? index + 1,
            type: switch (cores[index]['type']) {
              'performance' => 'performance',
              'efficiency' => 'efficiency',
              _ => null,
            },
            usage: _percent(deltas[index]?.$1, deltas[index]?.$2),
            userUsage: _percent(deltas[index]?.$3, deltas[index]?.$2),
            systemUsage: _percent(deltas[index]?.$4, deltas[index]?.$2),
          ),
      ]),
      memory: ActivityMemory._fromMap(_map(raw['memory'])),
      disk: ActivityDisk._fromSamples(
        _map(raw['disk']),
        _map(previous?['disk']),
        elapsed,
      ),
      network: ActivityNetwork._fromSamples(
        _map(raw['network']),
        _map(previous?['network']),
        elapsed,
      ),
      gpus: List.unmodifiable([
        for (final gpu in _maps(raw['gpu']))
          ActivityGpu(
            name: _text(gpu['name']),
            usage: _utilization(gpu['utilization']),
          ),
      ]),
      processCount: _counter(raw['processes']),
      threadCount: _counter(raw['threads']),
      readableProcessCount: _counter(raw['processes_readable']),
      threadCountComplete: raw['threads_complete'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'architecture': architecture,
    'model': model,
    'cpu_brand': cpuBrand,
    if (cpuUsage != null) 'cpu_usage': cpuUsage,
    if (cpuUserUsage != null) 'cpu_user_usage': cpuUserUsage,
    if (cpuSystemUsage != null) 'cpu_system_usage': cpuSystemUsage,
    'cores': cores.map((c) => c.toJson()).toList(),
    'memory': memory.toJson(),
    'disk': disk.toJson(),
    'network': network.toJson(),
    'gpus': gpus.map((g) => g.toJson()).toList(),
    if (processCount != null) 'process_count': processCount,
    if (threadCount != null) 'thread_count': threadCount,
    if (readableProcessCount != null)
      'readable_process_count': readableProcessCount,
    'thread_count_complete': threadCountComplete,
  };

  factory ActivitySnapshot.fromJson(Map<String, dynamic> json) {
    return ActivitySnapshot(
      timestamp: DateTime.parse(json['timestamp'] as String),
      architecture: _text(json['architecture']),
      model: _text(json['model']),
      cpuBrand: _text(json['cpu_brand']),
      cpuUsage: (json['cpu_usage'] as num?)?.toDouble(),
      cpuUserUsage: (json['cpu_user_usage'] as num?)?.toDouble(),
      cpuSystemUsage: (json['cpu_system_usage'] as num?)?.toDouble(),
      cores: List.unmodifiable(
        _maps(json['cores']).map((c) => ActivityCpuCore.fromJson(c)),
      ),
      memory: ActivityMemory.fromJson(_map(json['memory'])),
      disk: ActivityDisk.fromJson(_map(json['disk'])),
      network: ActivityNetwork.fromJson(_map(json['network'])),
      gpus: List.unmodifiable(
        _maps(json['gpus']).map((g) => ActivityGpu.fromJson(g)),
      ),
      processCount: _counter(json['process_count']),
      threadCount: _counter(json['thread_count']),
      readableProcessCount: _counter(json['readable_process_count']),
      threadCountComplete: json['thread_count_complete'] == true,
    );
  }
}

class ActivityCpuCore {
  const ActivityCpuCore({
    required this.id,
    this.type,
    this.usage,
    this.userUsage,
    this.systemUsage,
  });

  final int id;
  final String? type;
  final double? usage;
  final double? userUsage;
  final double? systemUsage;

  Map<String, dynamic> toJson() => {
    'id': id,
    if (type != null) 'type': type,
    if (usage != null) 'usage': usage,
    if (userUsage != null) 'user_usage': userUsage,
    if (systemUsage != null) 'system_usage': systemUsage,
  };

  factory ActivityCpuCore.fromJson(Map<String, dynamic> json) =>
      ActivityCpuCore(
        id: _counter(json['id']) ?? 1,
        type: json['type'] as String?,
        usage: (json['usage'] as num?)?.toDouble(),
        userUsage: (json['user_usage'] as num?)?.toDouble(),
        systemUsage: (json['system_usage'] as num?)?.toDouble(),
      );
}

class ActivityMemory {
  const ActivityMemory({
    this.totalBytes,
    this.usedBytes,
    this.appBytes,
    this.cachedBytes,
    this.freeBytes,
    this.activeBytes,
    this.inactiveBytes,
    this.wiredBytes,
    this.compressedBytes,
    this.purgeableBytes,
    this.swapUsedBytes,
    this.swapTotalBytes,
    this.pressure,
    this.usage,
  });

  final int? totalBytes;
  final int? usedBytes;
  final int? appBytes;
  final int? cachedBytes;
  final int? freeBytes;
  final int? activeBytes;
  final int? inactiveBytes;
  final int? wiredBytes;
  final int? compressedBytes;
  final int? purgeableBytes;
  final int? swapUsedBytes;
  final int? swapTotalBytes;
  final int? pressure;
  final double? usage;

  factory ActivityMemory._fromMap(Map<String, dynamic> raw) {
    final total = _counter(raw['physical']);
    final available = _counter(raw['available']);
    final active = _counter(raw['active']);
    final anonymous = _counter(raw['anonymous']);
    final purgeable = _counter(raw['purgeable']);
    final wired = _counter(raw['wired']);
    final compressed = _counter(raw['compressed']);
    final pressure = _counter(raw['pressure']);
    final app = anonymous != null && purgeable != null
        ? (anonymous > purgeable ? anonymous - purgeable : 0)
        : null;
    final used = raw.containsKey('available')
        ? (total != null && total > 0 && available != null && available <= total
            ? total - available
            : null)
        : _sum([app, wired, compressed]);
    return ActivityMemory(
      totalBytes: total,
      usedBytes: used,
      appBytes: app,
      cachedBytes: _sum([_counter(raw['file_backed']), purgeable]),
      freeBytes: _counter(raw['free']),
      activeBytes: active,
      inactiveBytes: _counter(raw['inactive']),
      wiredBytes: wired,
      compressedBytes: compressed,
      purgeableBytes: purgeable,
      swapUsedBytes: _counter(raw['swap_used']),
      swapTotalBytes: _counter(raw['swap_total']),
      pressure: [1, 2, 4].contains(pressure) ? pressure : null,
      usage: _percent(used, total),
    );
  }

  Map<String, dynamic> toJson() => {
    if (totalBytes != null) 'total_bytes': totalBytes,
    if (usedBytes != null) 'used_bytes': usedBytes,
    if (appBytes != null) 'app_bytes': appBytes,
    if (cachedBytes != null) 'cached_bytes': cachedBytes,
    if (freeBytes != null) 'free_bytes': freeBytes,
    if (activeBytes != null) 'active_bytes': activeBytes,
    if (inactiveBytes != null) 'inactive_bytes': inactiveBytes,
    if (wiredBytes != null) 'wired_bytes': wiredBytes,
    if (compressedBytes != null) 'compressed_bytes': compressedBytes,
    if (purgeableBytes != null) 'purgeable_bytes': purgeableBytes,
    if (swapUsedBytes != null) 'swap_used_bytes': swapUsedBytes,
    if (swapTotalBytes != null) 'swap_total_bytes': swapTotalBytes,
    if (pressure != null) 'pressure': pressure,
    if (usage != null) 'usage': usage,
  };

  factory ActivityMemory.fromJson(Map<String, dynamic> json) => ActivityMemory(
    totalBytes: _counter(json['total_bytes']),
    usedBytes: _counter(json['used_bytes']),
    appBytes: _counter(json['app_bytes']),
    cachedBytes: _counter(json['cached_bytes']),
    freeBytes: _counter(json['free_bytes']),
    activeBytes: _counter(json['active_bytes']),
    inactiveBytes: _counter(json['inactive_bytes']),
    wiredBytes: _counter(json['wired_bytes']),
    compressedBytes: _counter(json['compressed_bytes']),
    purgeableBytes: _counter(json['purgeable_bytes']),
    swapUsedBytes: _counter(json['swap_used_bytes']),
    swapTotalBytes: _counter(json['swap_total_bytes']),
    pressure: _counter(json['pressure']),
    usage: (json['usage'] as num?)?.toDouble(),
  );
}

class ActivityDisk {
  const ActivityDisk({
    this.available = false,
    this.devices = const [],
    this.readBytes,
    this.writeBytes,
    this.readOperations,
    this.writeOperations,
    this.readBytesPerSecond,
    this.writeBytesPerSecond,
    this.readOperationsPerSecond,
    this.writeOperationsPerSecond,
  });

  final bool available;
  final List<String> devices;
  final int? readBytes;
  final int? writeBytes;
  final int? readOperations;
  final int? writeOperations;
  final double? readBytesPerSecond;
  final double? writeBytesPerSecond;
  final double? readOperationsPerSecond;
  final double? writeOperationsPerSecond;

  factory ActivityDisk._fromSamples(
    Map<String, dynamic> raw,
    Map<String, dynamic> previous,
    double? elapsed,
  ) {
    final devices = _strings(raw['devices']);
    final previousDevices = _strings(previous['devices']);
    final available = raw['available'] == true;
    final comparable = available &&
        previous['available'] == true &&
        devices.isNotEmpty &&
        devices.toSet().length == devices.length &&
        previousDevices.toSet().length == previousDevices.length &&
        devices.length == previousDevices.length &&
        devices.toSet().containsAll(previousDevices);
    double? rate(String key) =>
        comparable ? _rate(raw[key], previous[key], elapsed) : null;
    return ActivityDisk(
      available: available,
      devices: List.unmodifiable(devices),
      readBytes: available ? _counter(raw['read_bytes']) : null,
      writeBytes: available ? _counter(raw['write_bytes']) : null,
      readOperations: available ? _counter(raw['read_ops']) : null,
      writeOperations: available ? _counter(raw['write_ops']) : null,
      readBytesPerSecond: rate('read_bytes'),
      writeBytesPerSecond: rate('write_bytes'),
      readOperationsPerSecond: rate('read_ops'),
      writeOperationsPerSecond: rate('write_ops'),
    );
  }

  Map<String, dynamic> toJson() => {
    'available': available,
    'devices': devices,
    if (readBytes != null) 'read_bytes': readBytes,
    if (writeBytes != null) 'write_bytes': writeBytes,
    if (readOperations != null) 'read_operations': readOperations,
    if (writeOperations != null) 'write_operations': writeOperations,
    if (readBytesPerSecond != null)
      'read_bytes_per_second': readBytesPerSecond,
    if (writeBytesPerSecond != null)
      'write_bytes_per_second': writeBytesPerSecond,
    if (readOperationsPerSecond != null)
      'read_operations_per_second': readOperationsPerSecond,
    if (writeOperationsPerSecond != null)
      'write_operations_per_second': writeOperationsPerSecond,
  };

  factory ActivityDisk.fromJson(Map<String, dynamic> json) => ActivityDisk(
    available: json['available'] == true,
    devices: _strings(json['devices']),
    readBytes: _counter(json['read_bytes']),
    writeBytes: _counter(json['write_bytes']),
    readOperations: _counter(json['read_operations']),
    writeOperations: _counter(json['write_operations']),
    readBytesPerSecond: (json['read_bytes_per_second'] as num?)?.toDouble(),
    writeBytesPerSecond: (json['write_bytes_per_second'] as num?)?.toDouble(),
    readOperationsPerSecond:
        (json['read_operations_per_second'] as num?)?.toDouble(),
    writeOperationsPerSecond:
        (json['write_operations_per_second'] as num?)?.toDouble(),
  );
}

class ActivityNetwork {
  const ActivityNetwork({
    this.available = false,
    this.interfaces = const [],
    this.receivedBytes,
    this.sentBytes,
    this.receivedBytesPerSecond,
    this.sentBytesPerSecond,
    this.receivedPackets,
    this.sentPackets,
    this.receivedPacketsPerSecond,
    this.sentPacketsPerSecond,
  });

  final bool available;
  final List<ActivityNetworkInterface> interfaces;
  final int? receivedBytes;
  final int? sentBytes;
  final double? receivedBytesPerSecond;
  final double? sentBytesPerSecond;
  final int? receivedPackets;
  final int? sentPackets;
  final double? receivedPacketsPerSecond;
  final double? sentPacketsPerSecond;

  factory ActivityNetwork._fromSamples(
    Map<String, dynamic> raw,
    Map<String, dynamic> previous,
    double? elapsed,
  ) {
    final available = raw['available'] == true;
    final oldInterfaces = {
      for (final interface in _maps(previous['interfaces']))
        if (interface['name'] is String) interface['name']: interface,
    };
    final comparable = available && previous['available'] == true;
    final interfaces = [
      for (final interface in _maps(raw['interfaces']))
        if (interface['name'] is String &&
            (interface['name'] as String).isNotEmpty)
          ActivityNetworkInterface(
            name: interface['name'] as String,
            receivedBytes: available ? _counter(interface['rx_bytes']) : null,
            sentBytes: available ? _counter(interface['tx_bytes']) : null,
            receivedPackets:
                available ? _counter(interface['rx_packets']) : null,
            sentPackets: available ? _counter(interface['tx_packets']) : null,
            receivedBytesPerSecond: comparable
                ? _rate(interface['rx_bytes'],
                    oldInterfaces[interface['name']]?['rx_bytes'], elapsed)
                : null,
            sentBytesPerSecond: comparable
                ? _rate(interface['tx_bytes'],
                    oldInterfaces[interface['name']]?['tx_bytes'], elapsed)
                : null,
            receivedPacketsPerSecond: comparable
                ? _rate(interface['rx_packets'],
                    oldInterfaces[interface['name']]?['rx_packets'], elapsed)
                : null,
            sentPacketsPerSecond: comparable
                ? _rate(interface['tx_packets'],
                    oldInterfaces[interface['name']]?['tx_packets'], elapsed)
                : null,
          ),
    ];
    final shared = interfaces
        .where((interface) => oldInterfaces.containsKey(interface.name))
        .toList();
    double? rate(double? Function(ActivityNetworkInterface) value) {
      if (shared.isEmpty) return null;
      final values = shared.map(value).toList();
      if (values.any((value) => value == null)) return null;
      return values.fold<double>(0, (total, value) => total + value!);
    }

    return ActivityNetwork(
      available: available,
      interfaces: List.unmodifiable(interfaces),
      receivedBytes: interfaces.isEmpty
          ? null
          : _sum(interfaces.map((interface) => interface.receivedBytes)),
      sentBytes: interfaces.isEmpty
          ? null
          : _sum(interfaces.map((interface) => interface.sentBytes)),
      receivedBytesPerSecond:
          rate((interface) => interface.receivedBytesPerSecond),
      sentBytesPerSecond: rate((interface) => interface.sentBytesPerSecond),
      receivedPackets: interfaces.isEmpty
          ? null
          : _sum(interfaces.map((interface) => interface.receivedPackets)),
      sentPackets: interfaces.isEmpty
          ? null
          : _sum(interfaces.map((interface) => interface.sentPackets)),
      receivedPacketsPerSecond:
          rate((interface) => interface.receivedPacketsPerSecond),
      sentPacketsPerSecond: rate((interface) => interface.sentPacketsPerSecond),
    );
  }

  Map<String, dynamic> toJson() => {
    'available': available,
    'interfaces': interfaces.map((i) => i.toJson()).toList(),
    if (receivedBytes != null) 'received_bytes': receivedBytes,
    if (sentBytes != null) 'sent_bytes': sentBytes,
    if (receivedBytesPerSecond != null)
      'received_bytes_per_second': receivedBytesPerSecond,
    if (sentBytesPerSecond != null)
      'sent_bytes_per_second': sentBytesPerSecond,
    if (receivedPackets != null) 'received_packets': receivedPackets,
    if (sentPackets != null) 'sent_packets': sentPackets,
    if (receivedPacketsPerSecond != null)
      'received_packets_per_second': receivedPacketsPerSecond,
    if (sentPacketsPerSecond != null)
      'sent_packets_per_second': sentPacketsPerSecond,
  };

  factory ActivityNetwork.fromJson(Map<String, dynamic> json) =>
      ActivityNetwork(
        available: json['available'] == true,
        interfaces: List.unmodifiable(
          _maps(json['interfaces']).map((i) => ActivityNetworkInterface.fromJson(i)),
        ),
        receivedBytes: _counter(json['received_bytes']),
        sentBytes: _counter(json['sent_bytes']),
        receivedBytesPerSecond:
            (json['received_bytes_per_second'] as num?)?.toDouble(),
        sentBytesPerSecond:
            (json['sent_bytes_per_second'] as num?)?.toDouble(),
        receivedPackets: _counter(json['received_packets']),
        sentPackets: _counter(json['sent_packets']),
        receivedPacketsPerSecond:
            (json['received_packets_per_second'] as num?)?.toDouble(),
        sentPacketsPerSecond:
            (json['sent_packets_per_second'] as num?)?.toDouble(),
      );
}

class ActivityNetworkInterface {
  const ActivityNetworkInterface({
    required this.name,
    this.receivedBytes,
    this.sentBytes,
    this.receivedBytesPerSecond,
    this.sentBytesPerSecond,
    this.receivedPackets,
    this.sentPackets,
    this.receivedPacketsPerSecond,
    this.sentPacketsPerSecond,
  });

  final String name;
  final int? receivedBytes;
  final int? sentBytes;
  final double? receivedBytesPerSecond;
  final double? sentBytesPerSecond;
  final int? receivedPackets;
  final int? sentPackets;
  final double? receivedPacketsPerSecond;
  final double? sentPacketsPerSecond;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (receivedBytes != null) 'received_bytes': receivedBytes,
    if (sentBytes != null) 'sent_bytes': sentBytes,
    if (receivedBytesPerSecond != null)
      'received_bytes_per_second': receivedBytesPerSecond,
    if (sentBytesPerSecond != null)
      'sent_bytes_per_second': sentBytesPerSecond,
    if (receivedPackets != null) 'received_packets': receivedPackets,
    if (sentPackets != null) 'sent_packets': sentPackets,
    if (receivedPacketsPerSecond != null)
      'received_packets_per_second': receivedPacketsPerSecond,
    if (sentPacketsPerSecond != null)
      'sent_packets_per_second': sentPacketsPerSecond,
  };

  factory ActivityNetworkInterface.fromJson(Map<String, dynamic> json) =>
      ActivityNetworkInterface(
        name: _text(json['name']),
        receivedBytes: _counter(json['received_bytes']),
        sentBytes: _counter(json['sent_bytes']),
        receivedBytesPerSecond:
            (json['received_bytes_per_second'] as num?)?.toDouble(),
        sentBytesPerSecond:
            (json['sent_bytes_per_second'] as num?)?.toDouble(),
        receivedPackets: _counter(json['received_packets']),
        sentPackets: _counter(json['sent_packets']),
        receivedPacketsPerSecond:
            (json['received_packets_per_second'] as num?)?.toDouble(),
        sentPacketsPerSecond:
            (json['sent_packets_per_second'] as num?)?.toDouble(),
      );
}

class ActivityGpu {
  const ActivityGpu({required this.name, this.usage});

  final String name;
  final double? usage;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (usage != null) 'usage': usage,
  };

  factory ActivityGpu.fromJson(Map<String, dynamic> json) => ActivityGpu(
    name: _text(json['name']),
    usage: (json['usage'] as num?)?.toDouble(),
  );
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};
List<Map<String, dynamic>> _maps(dynamic value) => value is List
    ? value
        .whereType<Map>()
        .map((value) => Map<String, dynamic>.from(value))
        .toList()
    : const [];
List<String> _strings(dynamic value) =>
    value is List ? value.whereType<String>().toList() : const [];
String _text(dynamic value) => value is String ? value : '';
int? _counter(dynamic value) => value is int && value >= 0 ? value : null;
int? _delta(dynamic value, dynamic previous) {
  final now = _counter(value);
  final before = _counter(previous);
  return now != null && before != null && now >= before ? now - before : null;
}

int? _sum(Iterable<int?> values) {
  var total = 0;
  for (final value in values) {
    if (value == null) return null;
    total += value;
  }
  return total;
}

double? _percent(int? value, int? total) =>
    value != null && total != null && total > 0
        ? (value / total * 100).clamp(0.0, 100.0)
        : null;
double? _utilization(dynamic value) =>
    value is num && value.isFinite && value >= 0 && value <= 100
        ? value.toDouble()
        : null;
double? _rate(dynamic value, dynamic previous, double? elapsed) {
  final delta = _delta(value, previous);
  return delta != null && elapsed != null && elapsed > 0
      ? delta / elapsed
      : null;
}

(int, int, int, int)? _cpuDelta(
    Map<String, dynamic> core, Map<String, dynamic>? previous) {
  if (previous == null) return null;
  final user = _delta(core['user'], previous['user']);
  final system = _delta(core['system'], previous['system']);
  final nice = _delta(core['nice'], previous['nice']);
  final idle = _delta(core['idle'], previous['idle']);
  if (user == null || system == null || nice == null || idle == null) {
    return null;
  }
  final active = user + system + nice;
  final total = active + idle;
  return total > 0 ? (active, total, user + nice, system) : null;
}
