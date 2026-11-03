import 'package:app_system_metrics/app_system_metrics.dart' as sys;
import 'package:monitor_models/monitor_models.dart' as m;

sys.ActivitySnapshot toAppMetricsSnapshot(m.ActivitySnapshot s) {
  return sys.ActivitySnapshot(
    timestamp: s.timestamp,
    architecture: s.architecture,
    model: s.model,
    cpuBrand: s.cpuBrand,
    cpuUsage: s.cpuUsage,
    cpuUserUsage: s.cpuUserUsage,
    cpuSystemUsage: s.cpuSystemUsage,
    cores: s.cores.map((c) => sys.ActivityCpuCore(
      id: c.id,
      type: c.type,
      usage: c.usage,
      userUsage: c.userUsage,
      systemUsage: c.systemUsage,
    )).toList(),
    memory: sys.ActivityMemory(
      totalBytes: s.memory.totalBytes,
      usedBytes: s.memory.usedBytes,
      appBytes: s.memory.appBytes,
      cachedBytes: s.memory.cachedBytes,
      freeBytes: s.memory.freeBytes,
      activeBytes: s.memory.activeBytes,
      inactiveBytes: s.memory.inactiveBytes,
      wiredBytes: s.memory.wiredBytes,
      compressedBytes: s.memory.compressedBytes,
      purgeableBytes: s.memory.purgeableBytes,
      swapUsedBytes: s.memory.swapUsedBytes,
      swapTotalBytes: s.memory.swapTotalBytes,
      pressure: s.memory.pressure,
      usage: s.memory.usage,
    ),
    disk: sys.ActivityDisk(
      available: s.disk.available,
      devices: s.disk.devices,
      readBytes: s.disk.readBytes,
      writeBytes: s.disk.writeBytes,
      readOperations: s.disk.readOperations,
      writeOperations: s.disk.writeOperations,
      readBytesPerSecond: s.disk.readBytesPerSecond,
      writeBytesPerSecond: s.disk.writeBytesPerSecond,
      readOperationsPerSecond: s.disk.readOperationsPerSecond,
      writeOperationsPerSecond: s.disk.writeOperationsPerSecond,
    ),
    network: sys.ActivityNetwork(
      available: s.network.available,
      interfaces: s.network.interfaces.map((i) => sys.ActivityNetworkInterface(
        name: i.name,
        receivedBytes: i.receivedBytes,
        sentBytes: i.sentBytes,
        receivedBytesPerSecond: i.receivedBytesPerSecond,
        sentBytesPerSecond: i.sentBytesPerSecond,
        receivedPackets: i.receivedPackets,
        sentPackets: i.sentPackets,
        receivedPacketsPerSecond: i.receivedPacketsPerSecond,
        sentPacketsPerSecond: i.sentPacketsPerSecond,
      )).toList(),
      receivedBytes: s.network.receivedBytes,
      sentBytes: s.network.sentBytes,
      receivedBytesPerSecond: s.network.receivedBytesPerSecond,
      sentBytesPerSecond: s.network.sentBytesPerSecond,
      receivedPackets: s.network.receivedPackets,
      sentPackets: s.network.sentPackets,
      receivedPacketsPerSecond: s.network.receivedPacketsPerSecond,
      sentPacketsPerSecond: s.network.sentPacketsPerSecond,
    ),
    gpus: s.gpus.map((g) => sys.ActivityGpu(
      name: g.name,
      usage: g.usage,
    )).toList(),
    processCount: s.processCount,
    threadCount: s.threadCount,
    readableProcessCount: s.readableProcessCount,
    threadCountComplete: s.threadCountComplete,
  );
}

sys.ActivitySnapshot systemMetricsToActivitySnapshot(
  m.SystemMetrics metrics,
  m.HostInfo? hostInfo, {
  DateTime? timestamp,
}) {
  final now = timestamp ?? DateTime.now();
  final cpu = metrics.cpu;
  final memory = metrics.memory;
  return sys.ActivitySnapshot(
    timestamp: now,
    architecture: hostInfo?.os ?? '',
    model: hostInfo?.hostname ?? '',
    cpuBrand: hostInfo?.cpuModel.isNotEmpty == true ? hostInfo!.cpuModel : 'CPU',
    cpuUsage: cpu?.usagePercent,
    cores: [
      if (cpu != null)
        for (var i = 0; i < cpu.perCore.length; i++)
          sys.ActivityCpuCore(
            id: i + 1,
            type: 'performance',
            usage: cpu.perCore[i],
          ),
    ],
    memory: sys.ActivityMemory(
      totalBytes: memory?.totalBytes,
      usedBytes: memory?.usedBytes,
      freeBytes: memory != null && memory.totalBytes >= memory.usedBytes
          ? (memory.totalBytes - memory.usedBytes)
          : null,
      swapTotalBytes: memory?.swapTotalBytes,
      swapUsedBytes: memory?.swapUsedBytes,
      pressure: 1,
      usage: memory?.usagePercent,
    ),
    disk: sys.ActivityDisk(
      available: metrics.disks.isNotEmpty,
      devices: metrics.disks.map((d) => d.device).toList(),
      readBytes: metrics.disks.fold<int>(0, (sum, d) => sum + d.readBytesPerSec),
      writeBytes: metrics.disks.fold<int>(0, (sum, d) => sum + d.writeBytesPerSec),
      readBytesPerSecond: metrics.disks.fold<double>(
        0.0,
        (sum, d) => sum + d.readBytesPerSec.toDouble(),
      ),
      writeBytesPerSecond: metrics.disks.fold<double>(
        0.0,
        (sum, d) => sum + d.writeBytesPerSec.toDouble(),
      ),
    ),
    network: sys.ActivityNetwork(
      available: metrics.networks.isNotEmpty,
      interfaces: metrics.networks
          .map(
            (n) => sys.ActivityNetworkInterface(
              name: n.interface_,
              receivedBytes: n.rxBytesPerSec,
              sentBytes: n.txBytesPerSec,
              receivedBytesPerSecond: n.rxBytesPerSec.toDouble(),
              sentBytesPerSecond: n.txBytesPerSec.toDouble(),
            ),
          )
          .toList(),
      receivedBytes:
          metrics.networks.fold<int>(0, (sum, n) => sum + n.rxBytesPerSec),
      sentBytes: metrics.networks.fold<int>(0, (sum, n) => sum + n.txBytesPerSec),
      receivedBytesPerSecond: metrics.networks.fold<double>(
        0.0,
        (sum, n) => sum + n.rxBytesPerSec.toDouble(),
      ),
      sentBytesPerSecond: metrics.networks.fold<double>(
        0.0,
        (sum, n) => sum + n.txBytesPerSec.toDouble(),
      ),
    ),
    gpus: metrics.gpus
        .map(
          (g) => sys.ActivityGpu(
            name: g.name,
            usage: g.usagePercent,
          ),
        )
        .toList(),
  );
}
