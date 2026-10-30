import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:monitor_agent/src/collectors/raw_collector.dart';
import 'package:monitor_agent/src/utils/process_runner.dart';

// Mach and sysctl constants
const int processorCpuLoadInfo = 2;
const int cpuStateUser = 0;
const int cpuStateSystem = 1;
const int cpuStateIdle = 2;
const int cpuStateNice = 3;
const int cpuStateMax = 4;

const int hostVmInfo64 = 4;
const int processorSetLoadInfo = 4;

base class XswUsage extends Struct {
  @Uint64()
  external int xsuTotal;
  @Uint64()
  external int xsuAvail;
  @Uint64()
  external int xsuUsed;
  @Uint32()
  external int xsuPagesize;
  @Int32()
  external int xsuEncrypted;
}

base class VmStatistics64 extends Struct {
  @Uint32()
  external int freeCount;
  @Uint32()
  external int activeCount;
  @Uint32()
  external int inactiveCount;
  @Uint32()
  external int wireCount;
  @Uint64()
  external int zeroFillCount;
  @Uint64()
  external int reactivations;
  @Uint64()
  external int pageins;
  @Uint64()
  external int pageouts;
  @Uint64()
  external int faults;
  @Uint64()
  external int cowFaults;
  @Uint64()
  external int lookups;
  @Uint64()
  external int hits;
  @Uint64()
  external int purges;
  @Uint32()
  external int purgeableCount;
  @Uint32()
  external int speculativeCount;
  @Uint64()
  external int decompressions;
  @Uint64()
  external int compressions;
  @Uint64()
  external int swapins;
  @Uint64()
  external int swapouts;
  @Uint32()
  external int compressorPageCount;
  @Uint32()
  external int throttledCount;
  @Uint32()
  external int externalPageCount;
  @Uint32()
  external int internalPageCount;
  @Uint64()
  external int totalUncompressedPagesInCompressor;
}

base class ProcessorSetLoadInfo extends Struct {
  @Int32()
  external int taskCount;
  @Int32()
  external int threadCount;
  @Int32()
  external int loadAverage1;
  @Int32()
  external int loadAverage2;
  @Int32()
  external int loadAverage3;
  @Int32()
  external int machFactor1;
  @Int32()
  external int machFactor2;
  @Int32()
  external int machFactor3;
}

typedef SysctlByNameC = Int32 Function(
  Pointer<Utf8> name,
  Pointer<Void> oldp,
  Pointer<IntPtr> oldlenp,
  Pointer<Void> newp,
  IntPtr newlen,
);

class MacosRawCollector implements RawCollector {
  MacosRawCollector() {
    _initDylib();
  }

  late final DynamicLibrary _dylib;
  late final int Function() _machHostSelf;
  late final int Function() _machTaskSelf;
  late final int Function(
    int, int, Pointer<Uint32>, Pointer<Pointer<Int32>>, Pointer<Uint32>,
  ) _hostProcessorInfo;
  late final int Function(int, Pointer<Void>, int) _vmDeallocate;
  late final int Function(
    int, int, Pointer<VmStatistics64>, Pointer<Uint32>,
  ) _hostStatistics64;
  late final int Function(int, Pointer<IntPtr>) _hostPageSize;
  late final int Function(
    Pointer<Utf8>, Pointer<Void>, Pointer<IntPtr>, Pointer<Void>, int,
  ) _sysctlbyname;
  late final int Function(int) _clockGettimeNsecNp;
  late final int Function(int, Pointer<Int32>) _processorSetDefault;
  late final int Function(
    int, int, Pointer<Void>, Pointer<Uint32>,
  ) _processorSetStatistics;

  String? _architecture;
  String? _model;
  String? _cpuBrand;
  int _pageSize = 4096;

  void _initDylib() {
    _dylib = DynamicLibrary.process();
    _machHostSelf = _dylib.lookupFunction<Int32 Function(), int Function()>('mach_host_self');
    _machTaskSelf = _dylib.lookupFunction<Int32 Function(), int Function()>('mach_task_self');
    _hostProcessorInfo = _dylib.lookupFunction<
      Int32 Function(Int32, Int32, Pointer<Uint32>, Pointer<Pointer<Int32>>, Pointer<Uint32>),
      int Function(int, int, Pointer<Uint32>, Pointer<Pointer<Int32>>, Pointer<Uint32>)
    >('host_processor_info');
    _vmDeallocate = _dylib.lookupFunction<
      Int32 Function(Int32, Pointer<Void>, IntPtr),
      int Function(int, Pointer<Void>, int)
    >('vm_deallocate');
    _hostStatistics64 = _dylib.lookupFunction<
      Int32 Function(Int32, Int32, Pointer<VmStatistics64>, Pointer<Uint32>),
      int Function(int, int, Pointer<VmStatistics64>, Pointer<Uint32>)
    >('host_statistics64');
    _hostPageSize = _dylib.lookupFunction<
      Int32 Function(Int32, Pointer<IntPtr>),
      int Function(int, Pointer<IntPtr>)
    >('host_page_size');
    _sysctlbyname = _dylib.lookupFunction<
      SysctlByNameC,
      int Function(Pointer<Utf8>, Pointer<Void>, Pointer<IntPtr>, Pointer<Void>, int)
    >('sysctlbyname');
    _clockGettimeNsecNp = _dylib.lookupFunction<
      Uint64 Function(Uint32),
      int Function(int)
    >('clock_gettime_nsec_np');
    _processorSetDefault = _dylib.lookupFunction<
      Int32 Function(Int32, Pointer<Int32>),
      int Function(int, Pointer<Int32>)
    >('processor_set_default');
    _processorSetStatistics = _dylib.lookupFunction<
      Int32 Function(Int32, Int32, Pointer<Void>, Pointer<Uint32>),
      int Function(int, int, Pointer<Void>, Pointer<Uint32>)
    >('processor_set_statistics');

    using((arena) {
      final sizePtr = arena<IntPtr>();
      if (_hostPageSize(_machHostSelf(), sizePtr) == 0) {
        _pageSize = sizePtr.value;
      }
    });
  }

  @override
  Future<Map<String, dynamic>> collectRaw() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final monotonic = _clockGettimeNsecNp(8) ~/ 1000000;
    final arch = _getArchitecture();
    final model = _getModel();
    final cpuBrand = _getCpuBrand();
    final cores = _readCores();
    final memory = _readMemory();
    final (processes, threads) = _readProcesses();

    final diskFuture = _readDisks();
    final networkFuture = _readNetwork();
    final gpuFuture = _readGpu();

    final results = await Future.wait([diskFuture, networkFuture, gpuFuture]);

    return {
      'timestamp_ms': now,
      'monotonic_ms': monotonic,
      'architecture': arch,
      'model': model,
      'cpu_brand': cpuBrand,
      'cores': cores,
      'memory': memory,
      'disk': results[0] as Map<String, dynamic>,
      'network': results[1] as Map<String, dynamic>,
      'gpu': results[2] as List<Map<String, dynamic>>,
      'processes': processes,
      'threads': threads,
      'processes_readable': processes,
      'threads_complete': threads != null,
    };
  }

  String _getArchitecture() {
    if (_architecture != null) return _architecture!;
    final v = Platform.version.toLowerCase();
    if (v.contains('arm64') || v.contains('aarch64')) {
      _architecture = 'arm64';
    } else {
      _architecture = 'x86_64';
    }
    return _architecture!;
  }

  String _getModel() {
    if (_model != null) return _model!;
    _model = _getSysctlString('hw.model') ?? 'Unknown Mac';
    return _model!;
  }

  String _getCpuBrand() {
    if (_cpuBrand != null) return _cpuBrand!;
    _cpuBrand = _getSysctlString('machdep.cpu.brand_string') ?? 'Unknown CPU';
    return _cpuBrand!;
  }

  String? _getSysctlString(String name) {
    return using((arena) {
      final namePtr = name.toNativeUtf8(allocator: arena);
      final sizePtr = arena<IntPtr>();
      if (_sysctlbyname(namePtr, nullptr, sizePtr, nullptr, 0) != 0) return null;
      final buf = arena<Uint8>(sizePtr.value);
      if (_sysctlbyname(namePtr, buf.cast<Void>(), sizePtr, nullptr, 0) == 0) {
        return buf.cast<Utf8>().toDartString();
      }
      return null;
    });
  }

  int? _getSysctlInt64(String name) {
    return using((arena) {
      final namePtr = name.toNativeUtf8(allocator: arena);
      final valPtr = arena<Int64>();
      final sizePtr = arena<IntPtr>();
      sizePtr.value = sizeOf<Int64>();
      if (_sysctlbyname(namePtr, valPtr.cast<Void>(), sizePtr, nullptr, 0) == 0) {
        return valPtr.value;
      }
      return null;
    });
  }

  int? _getSysctlInt32(String name) {
    return using((arena) {
      final namePtr = name.toNativeUtf8(allocator: arena);
      final valPtr = arena<Int32>();
      final sizePtr = arena<IntPtr>();
      sizePtr.value = sizeOf<Int32>();
      if (_sysctlbyname(namePtr, valPtr.cast<Void>(), sizePtr, nullptr, 0) == 0) {
        return valPtr.value;
      }
      return null;
    });
  }

  List<Map<String, dynamic>> _readCores() {
    final result = <Map<String, dynamic>>[];
    using((arena) {
      final host = _machHostSelf();
      final task = _machTaskSelf();
      final countPtr = arena<Uint32>();
      final infoPtr = arena<Pointer<Int32>>();
      final infoCountPtr = arena<Uint32>();

      final res = _hostProcessorInfo(
        host,
        processorCpuLoadInfo,
        countPtr,
        infoPtr,
        infoCountPtr,
      );
      if (res == 0) {
        final count = countPtr.value;
        final info = infoPtr.value;
        for (var i = 0; i < count; i++) {
          final base = i * cpuStateMax;
          final user = info[base + cpuStateUser];
          final sys = info[base + cpuStateSystem];
          final idle = info[base + cpuStateIdle];
          final nice = info[base + cpuStateNice];
          result.add({
            'id': i + 1,
            'type': null, // On macOS Silicon, ActivityMonitorCollector detects P/E via IODeviceTree
            'user': user >= 0 ? user : 0,
            'system': sys >= 0 ? sys : 0,
            'nice': nice >= 0 ? nice : 0,
            'idle': idle >= 0 ? idle : 0,
          });
        }
        _vmDeallocate(task, info.cast<Void>(), infoCountPtr.value * sizeOf<Int32>());
      }
    });
    return result;
  }

  Map<String, dynamic> _readMemory() {
    final physical = _getSysctlInt64('hw.memsize');
    final pressure = _getSysctlInt32('kern.memorystatus_vm_pressure_level');

    int? swapUsed;
    int? swapTotal;
    using((arena) {
      final namePtr = 'vm.swapusage'.toNativeUtf8(allocator: arena);
      final swapPtr = arena<XswUsage>();
      final sizePtr = arena<IntPtr>();
      sizePtr.value = sizeOf<XswUsage>();
      if (_sysctlbyname(namePtr, swapPtr.cast<Void>(), sizePtr, nullptr, 0) == 0) {
        swapUsed = swapPtr.ref.xsuUsed;
        swapTotal = swapPtr.ref.xsuTotal;
      }
    });

    int? freeBytes;
    int? activeBytes;
    int? inactiveBytes;
    int? wiredBytes;
    int? compressedBytes;
    int? purgeableBytes;
    int? fileBackedBytes;
    int? anonymousBytes;

    using((arena) {
      final stat = arena<VmStatistics64>();
      final count = arena<Uint32>();
      count.value = sizeOf<VmStatistics64>() ~/ sizeOf<Int32>();
      final res = _hostStatistics64(_machHostSelf(), hostVmInfo64, stat, count);
      if (res == 0) {
        freeBytes = stat.ref.freeCount * _pageSize;
        activeBytes = stat.ref.activeCount * _pageSize;
        inactiveBytes = stat.ref.inactiveCount * _pageSize;
        wiredBytes = stat.ref.wireCount * _pageSize;
        compressedBytes = stat.ref.compressorPageCount * _pageSize;
        purgeableBytes = stat.ref.purgeableCount * _pageSize;
        fileBackedBytes = stat.ref.externalPageCount * _pageSize;
        anonymousBytes = stat.ref.internalPageCount * _pageSize;
      }
    });

    return {
      'physical': ?physical,
      'free': ?freeBytes,
      'active': ?activeBytes,
      'inactive': ?inactiveBytes,
      'wired': ?wiredBytes,
      'compressed': ?compressedBytes,
      'purgeable': ?purgeableBytes,
      'file_backed': ?fileBackedBytes,
      'anonymous': ?anonymousBytes,
      'swap_used': ?swapUsed,
      'swap_total': ?swapTotal,
      if (pressure != null && [1, 2, 4].contains(pressure)) 'pressure': pressure,
    };
  }

  (int?, int?) _readProcesses() {
    return using((arena) {
      final host = _machHostSelf();
      final pset = arena<Int32>();
      if (_processorSetDefault(host, pset) == 0) {
        final info = arena<ProcessorSetLoadInfo>();
        final count = arena<Uint32>();
        count.value = sizeOf<ProcessorSetLoadInfo>() ~/ sizeOf<Int32>();
        if (_processorSetStatistics(pset.value, processorSetLoadInfo, info.cast<Void>(), count) == 0) {
          final tasks = info.ref.taskCount;
          final threads = info.ref.threadCount;
          return (tasks > 0 ? tasks : null, threads > 0 ? threads : null);
        }
      }
      return (null, null);
    });
  }

  Future<Map<String, dynamic>> _readNetwork() async {
    final interfaces = <Map<String, dynamic>>[];
    try {
      final result = await runProcess('netstat', ['-ibn']);
      if (result.exitCode == 0) {
        final lines = (result.stdout as String).split('\n');
        final seen = <String>{};
        for (final line in lines.skip(1)) {
          final parts = line.trim().split(RegExp(r'\s+'));
          if (parts.length < 10) continue;
          final name = parts[0];
          if (name.startsWith('lo') || !parts[2].contains('Link')) continue;
          if (seen.contains(name)) continue;
          seen.add(name);

          // netstat -ibn: Name Mtu Network Address Ipkts Ierrs Ibytes Opkts Oerrs Obytes Coll
          final rxPkts = int.tryParse(parts[4]);
          final rxBytes = int.tryParse(parts[6]);
          final txPkts = int.tryParse(parts[7]);
          final txBytes = int.tryParse(parts[9]);

          interfaces.add({
            'name': name,
            'rx_bytes': ?rxBytes,
            'tx_bytes': ?txBytes,
            'rx_packets': ?rxPkts,
            'tx_packets': ?txPkts,
          });
        }
      }
    } catch (_) {}

    return {
      'available': interfaces.isNotEmpty,
      'interfaces': interfaces,
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
      final result = await runProcess('iostat', ['-d', '-c', '1', '-I']);
      if (result.exitCode == 0) {
        final lines = (result.stdout as String).split('\n');
        if (lines.length >= 3) {
          final devLine = lines[0].trim().split(RegExp(r'\s+'));
          final valLine = lines[2].trim().split(RegExp(r'\s+'));
          // Each device has 3 columns: KB/t, xfrs, MB
          for (var i = 0; i < devLine.length; i++) {
            final dev = devLine[i];
            devices.add(dev);
            final valIdx = i * 3;
            if (valIdx + 2 < valLine.length) {
              final xfrs = int.tryParse(valLine[valIdx + 1]) ?? 0;
              final mb = double.tryParse(valLine[valIdx + 2]) ?? 0.0;
              final bytes = (mb * 1024 * 1024).round();
              totalReadOps += xfrs ~/ 2;
              totalWriteOps += xfrs ~/ 2;
              totalReadBytes += bytes ~/ 2;
              totalWriteBytes += bytes ~/ 2;
              hasData = true;
            }
          }
        }
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

  Future<List<Map<String, dynamic>>> _readGpu() async {
    final gpus = <Map<String, dynamic>>[];
    try {
      final result = await runProcess('ioreg', ['-rc', 'IOAccelerator', '-d', '2']);
      if (result.exitCode == 0) {
        final stdout = result.stdout as String;
        final blocks = stdout.split('+-o ');
        for (final block in blocks) {
          if (block.trim().isEmpty) continue;
          final nameMatch = RegExp(r'^(\S+)').firstMatch(block.trim());
          final name = nameMatch?.group(1)?.replaceAll('<', '').replaceAll('>', '');
          if (name == null || name == 'IOAccelerator') continue;
          if (name.contains('Context') ||
              name.contains('Client') ||
              name.contains('Surface') ||
              name.contains('Queue') ||
              name.contains('Pipe')) {
            continue;
          }

          final utilMatch = RegExp(r'"Device Utilization %"\s*=\s*(\d+)').firstMatch(block);
          final util = utilMatch != null ? double.tryParse(utilMatch.group(1)!) : null;
          if (util != null) {
            gpus.add({
              'name': name,
              'utilization': util,
            });
          }
        }
      }
    } catch (_) {}
    return gpus;
  }
}
