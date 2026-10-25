/// A device activity sample. Nullable measurements are unavailable or warming up.
class ActivitySnapshot {
  const ActivitySnapshot({
    required this.timestamp,
    required this.architecture,
    required this.model,
    required this.cpuBrand,
    required this.cpuUsage,
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
  ///
  /// Uses a monotonic clock for rates. Counter resets, topology changes, and
  /// missing counters produce null rather than fabricated zero measurements.
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
              usage: _utilization(gpu['utilization'])),
      ]),
      processCount: _counter(raw['processes']),
      threadCount: _counter(raw['threads']),
      readableProcessCount: _counter(raw['processes_readable']),
      threadCountComplete: raw['threads_complete'] == true,
    );
  }
}

class ActivityCpuCore {
  const ActivityCpuCore({required this.id, this.type, this.usage});

  /// Native logical CPU slot, starting at one.
  final int id;

  /// `performance`, `efficiency`, or null when the OS cannot identify the type.
  final String? type;
  final double? usage;
}

class ActivityMemory {
  const ActivityMemory({
    this.totalBytes,
    this.usedBytes,
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

  /// Non-purgeable anonymous + wired + compressor memory.
  final int? usedBytes;
  final int? freeBytes;
  final int? activeBytes;
  final int? inactiveBytes;
  final int? wiredBytes;
  final int? compressedBytes;
  final int? purgeableBytes;
  final int? swapUsedBytes;
  final int? swapTotalBytes;

  /// macOS memory pressure: 1 (normal), 2 (warning), 4 (critical).
  final int? pressure;
  final double? usage;

  factory ActivityMemory._fromMap(Map<String, dynamic> raw) {
    final total = _counter(raw['physical']);
    final active = _counter(raw['active']);
    final anonymous = _counter(raw['anonymous']);
    final purgeable = _counter(raw['purgeable']);
    final wired = _counter(raw['wired']);
    final compressed = _counter(raw['compressed']);
    final pressure = _counter(raw['pressure']);
    final app = anonymous != null && purgeable != null
        ? (anonymous > purgeable ? anonymous - purgeable : 0)
        : null;
    final used = _sum([app, wired, compressed]);
    return ActivityMemory(
      totalBytes: total,
      usedBytes: used,
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
}

class ActivityNetwork {
  const ActivityNetwork({
    this.available = false,
    this.interfaces = const [],
    this.receivedBytes,
    this.sentBytes,
    this.receivedBytesPerSecond,
    this.sentBytesPerSecond,
  });

  final bool available;
  final List<ActivityNetworkInterface> interfaces;
  final int? receivedBytes;
  final int? sentBytes;
  final double? receivedBytesPerSecond;
  final double? sentBytesPerSecond;

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
            receivedBytesPerSecond: comparable
                ? _rate(interface['rx_bytes'],
                    oldInterfaces[interface['name']]?['rx_bytes'], elapsed)
                : null,
            sentBytesPerSecond: comparable
                ? _rate(interface['tx_bytes'],
                    oldInterfaces[interface['name']]?['tx_bytes'], elapsed)
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
    );
  }
}

class ActivityNetworkInterface {
  const ActivityNetworkInterface({
    required this.name,
    this.receivedBytes,
    this.sentBytes,
    this.receivedBytesPerSecond,
    this.sentBytesPerSecond,
  });

  final String name;
  final int? receivedBytes;
  final int? sentBytes;
  final double? receivedBytesPerSecond;
  final double? sentBytesPerSecond;
}

class ActivityGpu {
  const ActivityGpu({required this.name, this.usage});

  final String name;
  final double? usage;
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

(int, int)? _cpuDelta(
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
  return total > 0 ? (active, total) : null;
}
