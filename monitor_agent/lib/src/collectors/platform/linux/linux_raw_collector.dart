import 'dart:io';

import 'package:monitor_agent/src/collectors/raw_collector.dart';

class LinuxRawCollector implements RawCollector {
  String? _architecture;
  String? _model;
  String? _cpuBrand;
  List<String?>? _coreTypes;

  @override
  Future<Map<String, dynamic>> collectRaw() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final monotonic = await _readMonotonicMs();
    final arch = _getArchitecture();
    final model = await _getModel();
    final brand = await _getCpuBrand();
    final cores = await _readCores();
    final memory = await _readMemory();
    final disk = await _readDisks();
    final network = await _readNetwork();
    final gpus = await _readGpus();
    final (processes, threads) = await _readProcesses();

    return {
      'timestamp_ms': now,
      'monotonic_ms': monotonic,
      'architecture': arch,
      'model': model,
      'cpu_brand': brand,
      'cores': cores,
      'memory': memory,
      'disk': disk,
      'network': network,
      'gpu': gpus,
      'processes': processes,
      'threads': threads,
      'processes_readable': processes,
      'threads_complete': threads != null,
    };
  }

  Future<int> _readMonotonicMs() async {
    try {
      final uptimeStr = await File('/proc/uptime').readAsString();
      final seconds = double.tryParse(uptimeStr.trim().split(' ').first) ?? 0;
      return (seconds * 1000).toInt();
    } catch (_) {
      return DateTime.now().millisecondsSinceEpoch;
    }
  }

  String _getArchitecture() {
    if (_architecture != null) return _architecture!;
    final v = Platform.version.toLowerCase();
    if (v.contains('arm64') || v.contains('aarch64')) {
      _architecture = 'arm64';
    } else if (v.contains('x64') || v.contains('x86_64')) {
      _architecture = 'x86_64';
    } else {
      _architecture = 'unknown';
    }
    return _architecture!;
  }

  Future<String> _getModel() async {
    if (_model != null) return _model!;
    try {
      final dmi = File('/sys/devices/virtual/dmi/id/product_name');
      if (await dmi.exists()) {
        final text = (await dmi.readAsString()).trim();
        if (text.isNotEmpty) {
          _model = text;
          return text;
        }
      }
    } catch (_) {}
    try {
      final dt = File('/proc/device-tree/model');
      if (await dt.exists()) {
        final text = (await dt.readAsString()).replaceAll('\x00', '').trim();
        if (text.isNotEmpty) {
          _model = text;
          return text;
        }
      }
    } catch (_) {}
    _model = 'Linux Device';
    return _model!;
  }

  Future<String> _getCpuBrand() async {
    if (_cpuBrand != null) return _cpuBrand!;
    try {
      final cpuinfo = await File('/proc/cpuinfo').readAsString();
      for (final line in cpuinfo.split('\n')) {
        if (line.startsWith('model name') || line.startsWith('Hardware')) {
          final parts = line.split(':');
          if (parts.length > 1) {
            _cpuBrand = parts[1].trim();
            return _cpuBrand!;
          }
        }
      }
    } catch (_) {}
    _cpuBrand = 'Unknown CPU';
    return _cpuBrand!;
  }

  Future<List<Map<String, dynamic>>> _readCores() async {
    final result = <Map<String, dynamic>>[];
    try {
      final stat = await File('/proc/stat').readAsString();
      var coreIndex = 0;
      for (final line in stat.split('\n')) {
        if (line.startsWith('cpu') && !line.startsWith('cpu ')) {
          // cpu0, cpu1, ...
          final parts = line.trim().split(RegExp(r'\s+'));
          if (parts.length >= 5) {
            final user = int.tryParse(parts[1]) ?? 0;
            final nice = int.tryParse(parts[2]) ?? 0;
            final system = int.tryParse(parts[3]) ?? 0;
            final idle = int.tryParse(parts[4]) ?? 0;
            final type = _getCoreType(coreIndex);
            result.add({
              'id': coreIndex + 1,
              'type': type,
              'user': user,
              'system': system,
              'nice': nice,
              'idle': idle,
            });
            coreIndex++;
          }
        }
      }
    } catch (_) {}
    return result;
  }

  String? _getCoreType(int index) {
    if (_coreTypes != null && index < _coreTypes!.length) {
      return _coreTypes![index];
    }
    // Try to detect once
    _detectCoreTypes();
    if (_coreTypes != null && index < _coreTypes!.length) {
      return _coreTypes![index];
    }
    return null;
  }

  void _detectCoreTypes() {
    try {
      final types = <String?>[];
      final cpuDir = Directory('/sys/devices/system/cpu');
      if (cpuDir.existsSync()) {
        final entries = cpuDir.listSync();
        final maxFreqs = <int, int>{};
        for (final entry in entries) {
          final name = entry.uri.pathSegments.where((s) => s.isNotEmpty).last;
          if (name.startsWith('cpu') && int.tryParse(name.substring(3)) != null) {
            final id = int.parse(name.substring(3));
            final maxFreqFile = File('${entry.path}/cpufreq/cpuinfo_max_freq');
            if (maxFreqFile.existsSync()) {
              maxFreqs[id] = int.tryParse(maxFreqFile.readAsStringSync().trim()) ?? 0;
            }
          }
        }
        if (maxFreqs.isNotEmpty) {
          final distinctFreqs = maxFreqs.values.toSet().toList()..sort();
          if (distinctFreqs.length >= 2) {
            final lowest = distinctFreqs.first;
            for (var i = 0; i < maxFreqs.length; i++) {
              final f = maxFreqs[i] ?? 0;
              types.add(f == lowest ? 'efficiency' : 'performance');
            }
            _coreTypes = types;
            return;
          }
        }
      }
    } catch (_) {}
  }

  Future<Map<String, dynamic>> _readMemory() async {
    final values = <String, int>{};
    try {
      final meminfo = await File('/proc/meminfo').readAsString();
      for (final line in meminfo.split('\n')) {
        final match = RegExp(r'^(\S+):\s+(\d+)\s+kB').firstMatch(line);
        if (match != null) {
          values[match.group(1)!] = (int.tryParse(match.group(2)!) ?? 0) * 1024;
        }
      }
    } catch (_) {}

    final total = values['MemTotal'];
    final free = values['MemFree'];
    final available = values['MemAvailable'];
    final active = values['Active'];
    final inactive = values['Inactive'];
    final buffers = values['Buffers'] ?? 0;
    final cached = values['Cached'] ?? 0;
    final swapTotal = values['SwapTotal'];
    final swapFree = values['SwapFree'];
    final swapUsed = (swapTotal != null && swapFree != null) ? swapTotal - swapFree : null;

    return {
      'physical': ?total,
      'free': ?free,
      'available': ?available,
      'active': ?active,
      'inactive': ?inactive,
      'file_backed': buffers + cached,
      'swap_used': ?swapUsed,
      'swap_total': ?swapTotal,
    };
  }

  Future<Map<String, dynamic>> _readDisks() async {
    final devices = <String>[];
    int totalReadBytes = 0;
    int totalWriteBytes = 0;
    int totalReadOps = 0;
    int totalWriteOps = 0;
    bool hasData = false;

    try {
      final diskstats = await File('/proc/diskstats').readAsString();
      for (final line in diskstats.split('\n')) {
        final parts = line.trim().split(RegExp(r'\s+'));
        if (parts.length < 14) continue;
        final dev = parts[2];

        // Skip loops, ram, partitions
        if (dev.startsWith('loop') || dev.startsWith('ram') || dev.startsWith('zram')) {
          continue;
        }
        if (RegExp(r'^(sd|vd)[a-z]\d').hasMatch(dev)) continue;
        if (RegExp(r'nvme\d+n\d+p\d+').hasMatch(dev)) continue;
        if (RegExp(r'mmcblk\d+p\d+').hasMatch(dev)) continue;

        devices.add(dev);
        final readOps = int.tryParse(parts[3]) ?? 0;
        final readSectors = int.tryParse(parts[5]) ?? 0;
        final writeOps = int.tryParse(parts[7]) ?? 0;
        final writeSectors = int.tryParse(parts[9]) ?? 0;

        totalReadOps += readOps;
        totalWriteOps += writeOps;
        totalReadBytes += readSectors * 512;
        totalWriteBytes += writeSectors * 512;
        hasData = true;
      }
    } catch (_) {}

    return {
      'available': hasData,
      'devices': devices,
      if (hasData) 'read_bytes': totalReadBytes,
      if (hasData) 'write_bytes': totalWriteBytes,
      if (hasData) 'read_ops': totalReadOps,
      if (hasData) 'write_ops': totalWriteOps,
    };
  }

  Future<Map<String, dynamic>> _readNetwork() async {
    final interfaces = <Map<String, dynamic>>[];
    try {
      final netdev = await File('/proc/net/dev').readAsString();
      for (final line in netdev.split('\n').skip(2)) {
        final colonIdx = line.indexOf(':');
        if (colonIdx < 0) continue;
        final iface = line.substring(0, colonIdx).trim();
        if (iface == 'lo') continue;

        final parts = line.substring(colonIdx + 1).trim().split(RegExp(r'\s+'));
        if (parts.length >= 10) {
          final rxBytes = int.tryParse(parts[0]);
          final rxPackets = int.tryParse(parts[1]);
          final txBytes = int.tryParse(parts[8]);
          final txPackets = int.tryParse(parts[9]);

          interfaces.add({
            'name': iface,
            'rx_bytes': ?rxBytes,
            'tx_bytes': ?txBytes,
            'rx_packets': ?rxPackets,
            'tx_packets': ?txPackets,
          });
        }
      }
    } catch (_) {}

    return {
      'available': interfaces.isNotEmpty,
      'interfaces': interfaces,
    };
  }

  Future<List<Map<String, dynamic>>> _readGpus() async {
    final gpus = <Map<String, dynamic>>[];
    try {
      // Check DRM sysfs
      final drmDir = Directory('/sys/class/drm');
      if (await drmDir.exists()) {
        for (final entry in await drmDir.list().toList()) {
          final name = entry.uri.pathSegments.where((s) => s.isNotEmpty).last;
          if (name.startsWith('card') && !name.contains('-')) {
            final busyFile = File('${entry.path}/device/gpu_busy_percent');
            if (await busyFile.exists()) {
              final utilStr = (await busyFile.readAsString()).trim();
              final util = double.tryParse(utilStr);
              gpus.add({'name': name, 'utilization': ?util});
            }
          }
        }
      }
    } catch (_) {}
    return gpus;
  }

  Future<(int?, int?)> _readProcesses() async {
    try {
      final procDir = Directory('/proc');
      var pCount = 0;
      var tCount = 0;
      for (final entry in procDir.listSync()) {
        final name = entry.uri.pathSegments.where((s) => s.isNotEmpty).last;
        if (int.tryParse(name) != null) {
          pCount++;
          try {
            final status = File('${entry.path}/status').readAsStringSync();
            final match = RegExp(r'^Threads:\s+(\d+)', multiLine: true).firstMatch(status);
            if (match != null) {
              tCount += int.tryParse(match.group(1)!) ?? 1;
            } else {
              tCount++;
            }
          } catch (_) {
            tCount++;
          }
        }
      }
      return (pCount > 0 ? pCount : null, tCount > 0 ? tCount : null);
    } catch (_) {
      return (null, null);
    }
  }
}
