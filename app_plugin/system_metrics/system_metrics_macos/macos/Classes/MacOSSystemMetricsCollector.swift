import Darwin
import Foundation
import IOKit

struct MacOSSystemMetricsSnapshot {
  let cpuUsage: Double
  let gpuUsage: Double
  let memoryUsage: Double
  let memoryUsedBytes: UInt64
  let memoryTotalBytes: UInt64
  let gpuModel: String?
  let gpuCoreCount: Int?
  let gpuMetricsSource: String
}

final class MacOSSystemMetricsCollector {
  private var previousCpuSample: CpuSample?

  func reset() {
    previousCpuSample = nil
  }

  func snapshot() -> MacOSSystemMetricsSnapshot {
    let cpuUsage = readCpuUsage()
    let memory = readMemoryUsage()
    let gpu = readGpuUsage()

    return MacOSSystemMetricsSnapshot(
      cpuUsage: cpuUsage,
      gpuUsage: gpu.usage,
      memoryUsage: memory.usage,
      memoryUsedBytes: memory.usedBytes,
      memoryTotalBytes: memory.totalBytes,
      gpuModel: gpu.model,
      gpuCoreCount: gpu.coreCount,
      gpuMetricsSource: gpu.source
    )
  }

  private func readCpuUsage() -> Double {
    guard let sample = readCpuSample() else {
      return readLoadAverageCpuUsage() ?? 0.0
    }

    defer {
      previousCpuSample = sample
    }

    guard let previous = previousCpuSample else {
      return readLoadAverageCpuUsage() ?? sample.usage
    }

    let activeDelta =
      sample.active > previous.active
      ? sample.active - previous.active
      : 0
    let totalDelta = sample.total > previous.total ? sample.total - previous.total : 0
    guard totalDelta > 0 else {
      return 0.0
    }

    return clampPercent(Double(activeDelta) / Double(totalDelta) * 100.0)
  }

  private func readCpuSample() -> CpuSample? {
    var processorCount: natural_t = 0
    var processorInfoCount: mach_msg_type_number_t = 0
    var processorInfo: processor_info_array_t?

    let result = host_processor_info(
      mach_host_self(),
      PROCESSOR_CPU_LOAD_INFO,
      &processorCount,
      &processorInfo,
      &processorInfoCount
    )

    guard result == KERN_SUCCESS, let processorInfo else {
      return nil
    }

    defer {
      let byteCount = vm_size_t(Int(processorInfoCount) * MemoryLayout<integer_t>.stride)
      vm_deallocate(
        mach_task_self_,
        vm_address_t(UInt(bitPattern: processorInfo)),
        byteCount
      )
    }

    var active: UInt64 = 0
    var total: UInt64 = 0
    let stride = Int(CPU_STATE_MAX)

    for index in 0..<Int(processorCount) {
      let base = index * stride
      let user = positiveTick(processorInfo[base + Int(CPU_STATE_USER)])
      let system = positiveTick(processorInfo[base + Int(CPU_STATE_SYSTEM)])
      let nice = positiveTick(processorInfo[base + Int(CPU_STATE_NICE)])
      let idle = positiveTick(processorInfo[base + Int(CPU_STATE_IDLE)])
      active += user + system + nice
      total += user + system + nice + idle
    }

    guard total > 0 else {
      return nil
    }

    return CpuSample(
      active: active,
      total: total,
      usage: clampPercent(Double(active) / Double(total) * 100.0)
    )
  }

  private func readLoadAverageCpuUsage() -> Double? {
    var loadAverage = [Double](repeating: 0.0, count: 3)
    guard getloadavg(&loadAverage, 1) == 1 else {
      return nil
    }

    let processorCount = max(1, ProcessInfo.processInfo.activeProcessorCount)
    return clampPercent(loadAverage[0] / Double(processorCount) * 100.0)
  }

  private func readMemoryUsage() -> MemorySample {
    let totalBytes = ProcessInfo.processInfo.physicalMemory
    var pageSize: vm_size_t = 0
    if host_page_size(mach_host_self(), &pageSize) != KERN_SUCCESS || pageSize == 0 {
      pageSize = vm_size_t(vm_kernel_page_size)
    }

    var stats = vm_statistics64()
    var count = mach_msg_type_number_t(
      MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride
    )
    let result = withUnsafeMutablePointer(to: &stats) { statsPointer in
      statsPointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
        host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
      }
    }

    guard result == KERN_SUCCESS, totalBytes > 0 else {
      return MemorySample(usage: 0.0, usedBytes: 0, totalBytes: totalBytes)
    }

    let usedPages =
      UInt64(stats.active_count) + UInt64(stats.wire_count) + UInt64(stats.compressor_page_count)
    let usedBytes = min(usedPages * UInt64(pageSize), totalBytes)
    let usage = clampPercent(Double(usedBytes) / Double(totalBytes) * 100.0)

    return MemorySample(usage: usage, usedBytes: usedBytes, totalBytes: totalBytes)
  }

  private func readGpuUsage() -> GpuSample {
    guard let matching = IOServiceMatching("IOAccelerator") else {
      return GpuSample(usage: 0.0, model: nil, coreCount: nil, source: "unavailable")
    }

    var iterator: io_iterator_t = 0
    let result = IOServiceGetMatchingServices(ioKitDefaultPort(), matching, &iterator)
    guard result == KERN_SUCCESS else {
      return GpuSample(usage: 0.0, model: nil, coreCount: nil, source: "unavailable")
    }

    defer {
      IOObjectRelease(iterator)
    }

    var usage: Double?
    var model: String?
    var coreCount: Int?
    var source = "unavailable"

    while true {
      let service = IOIteratorNext(iterator)
      if service == 0 {
        break
      }

      defer {
        IOObjectRelease(service)
      }

      model = model ?? stringProperty(service, "model")
      coreCount = coreCount ?? intProperty(service, "gpu-core-count")

      guard let stats = registryProperty(service, "PerformanceStatistics") as? NSDictionary else {
        continue
      }

      for key in ["Device Utilization %", "Renderer Utilization %", "Tiler Utilization %"] {
        guard let candidate = numericValue(stats[key]) else {
          continue
        }
        if usage == nil || candidate > usage! {
          usage = candidate
          source = "IOAccelerator PerformanceStatistics \(key)"
        }
      }
    }

    return GpuSample(
      usage: clampPercent(usage ?? 0.0),
      model: model,
      coreCount: coreCount,
      source: source
    )
  }

  private func registryProperty(_ service: io_object_t, _ name: String) -> Any? {
    IORegistryEntryCreateCFProperty(
      service,
      name as CFString,
      kCFAllocatorDefault,
      0
    )?.takeRetainedValue()
  }

  private func ioKitDefaultPort() -> mach_port_t {
    mach_port_t(MACH_PORT_NULL)
  }

  private func stringProperty(_ service: io_object_t, _ name: String) -> String? {
    let value = registryProperty(service, name)
    if let string = value as? String {
      return string
    }
    if let data = value as? Data {
      return String(data: data, encoding: .utf8)?
        .trimmingCharacters(in: .controlCharacters.union(.whitespacesAndNewlines))
    }
    return nil
  }

  private func intProperty(_ service: io_object_t, _ name: String) -> Int? {
    guard let number = registryProperty(service, name) as? NSNumber else {
      return nil
    }
    return number.intValue
  }

  private func numericValue(_ value: Any?) -> Double? {
    if let number = value as? NSNumber {
      return number.doubleValue
    }
    if let double = value as? Double {
      return double
    }
    if let int = value as? Int {
      return Double(int)
    }
    return nil
  }

  private func positiveTick(_ value: integer_t) -> UInt64 {
    UInt64(max(0, Int64(value)))
  }

  private func clampPercent(_ value: Double) -> Double {
    guard value.isFinite else {
      return 0.0
    }
    return min(100.0, max(0.0, value))
  }
}

private struct CpuSample {
  let active: UInt64
  let total: UInt64
  let usage: Double
}

private struct MemorySample {
  let usage: Double
  let usedBytes: UInt64
  let totalBytes: UInt64
}

private struct GpuSample {
  let usage: Double
  let model: String?
  let coreCount: Int?
  let source: String
}
