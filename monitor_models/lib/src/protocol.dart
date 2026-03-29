/// JSON key constants for the monitor WebSocket protocol.
abstract final class Protocol {
  static const String type = 'type';
  static const String payload = 'payload';

  // Message types
  static const String hostInfo = 'host_info';
  static const String metrics = 'metrics';
  static const String ping = 'ping';
  static const String pong = 'pong';
  static const String setInterval = 'set_interval';

  // Host info keys
  static const String hostname = 'hostname';
  static const String os = 'os';
  static const String osVersion = 'os_version';
  static const String cpuModel = 'cpu_model';
  static const String cpuCores = 'cpu_cores';
  static const String totalMemory = 'total_memory';
  static const String agentVersion = 'agent_version';
  static const String gpus = 'gpus';

  // GPU info keys
  static const String gpuIndex = 'index';
  static const String gpuName = 'name';
  static const String gpuMemoryTotal = 'memory_total';

  // CPU metrics keys
  static const String usagePercent = 'usage_percent';
  static const String perCore = 'per_core';
  static const String loadAvg = 'load_avg';

  // Memory metrics keys
  static const String usedBytes = 'used_bytes';
  static const String totalBytes = 'total_bytes';
  static const String swapUsedBytes = 'swap_used_bytes';
  static const String swapTotalBytes = 'swap_total_bytes';

  // GPU metrics keys
  static const String memoryUsedBytes = 'memory_used_bytes';
  static const String memoryTotalBytes = 'memory_total_bytes';
  static const String temperatureCelsius = 'temperature_celsius';

  // Network metrics keys
  static const String interface_ = 'interface';
  static const String txBytesPerSec = 'tx_bytes_per_sec';
  static const String rxBytesPerSec = 'rx_bytes_per_sec';

  // Disk metrics keys
  static const String device = 'device';
  static const String readBytesPerSec = 'read_bytes_per_sec';
  static const String writeBytesPerSec = 'write_bytes_per_sec';

  // System metrics keys
  static const String cpu = 'cpu';
  static const String memory = 'memory';
  static const String gpu = 'gpu';
  static const String network = 'network';
  static const String disk = 'disk';

  // Interval keys
  static const String seconds = 'seconds';

  // Minimum agent version the client expects
  static const String minAgentVersion = '1.0.0';
}
