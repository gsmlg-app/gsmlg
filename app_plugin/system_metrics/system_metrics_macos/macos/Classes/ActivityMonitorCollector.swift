import Darwin
import Foundation
import IOKit

/// Unprivileged cumulative counters. Each Dart monitor owns its interval baseline.
/// Based on hologram_demo/priv/native's Mach, sysctl and IOKit collector.
final class ActivityMonitorCollector {
  private let host = mach_host_self()

  deinit {
    mach_port_deallocate(mach_task_self_, host)
  }

  func snapshot() -> [String: Any] {
    #if arch(arm64)
    let architecture = "arm64"
    #else
    let architecture = "x86_64"
    #endif
    var result: [String: Any] = [
      "timestamp_ms": Int64(Date().timeIntervalSince1970 * 1000),
      "monotonic_ms": Int64(ProcessInfo.processInfo.systemUptime * 1000),
      "architecture": architecture,
      "model": sysctlString("hw.model") ?? "Unknown Mac",
      "cpu_brand": sysctlString("machdep.cpu.brand_string") ?? "Unknown CPU",
      "cores": cores(),
      "memory": memory(),
      "disk": disks(),
      "network": network(),
      "gpu": gpus(),
    ]
    result.merge(processCounts()) { _, new in new }
    return result
  }

  private func cores() -> [[String: Any]] {
    var count: natural_t = 0
    var info: processor_info_array_t?
    var infoCount: mach_msg_type_number_t = 0
    let status = host_processor_info(host, PROCESSOR_CPU_LOAD_INFO, &count, &info, &infoCount)
    guard status == KERN_SUCCESS, let info else { return [] }
    defer { release(info, count: infoCount) }
    guard Int(infoCount) >= Int(count) * Int(CPU_STATE_MAX) else { return [] }
    let types = coreTypes(count: Int(count))
    return (0..<Int(count)).map { index in
      let base = index * Int(CPU_STATE_MAX)
      return [
        "id": index + 1,
        "type": types[index] as Any? ?? NSNull(),
        "user": UInt64(UInt32(bitPattern: info[base + Int(CPU_STATE_USER)])),
        "system": UInt64(UInt32(bitPattern: info[base + Int(CPU_STATE_SYSTEM)])),
        "nice": UInt64(UInt32(bitPattern: info[base + Int(CPU_STATE_NICE)])),
        "idle": UInt64(UInt32(bitPattern: info[base + Int(CPU_STATE_IDLE)])),
      ]
    }
  }

  private func coreTypes(count: Int) -> [String?] {
    var types = [String?](repeating: nil, count: count)
    #if arch(arm64)
    var basicCount: natural_t = 0
    var info: processor_info_array_t?
    var infoCount: mach_msg_type_number_t = 0
    guard host_processor_info(host, PROCESSOR_BASIC_INFO, &basicCount, &info, &infoCount)
      == KERN_SUCCESS, let info else { return types }
    defer { release(info, count: infoCount) }
    let stride = MemoryLayout<processor_basic_info_data_t>.stride / MemoryLayout<integer_t>.stride
    guard Int(basicCount) == count, Int(infoCount) >= count * stride else { return types }
    let cpus = IORegistryEntryFromPath(0, "IODeviceTree:/cpus")
    guard cpus != 0 else { return types }
    defer { IOObjectRelease(cpus) }
    var children: io_iterator_t = 0
    guard IORegistryEntryGetChildIterator(cpus, kIODeviceTreePlane, &children) == KERN_SUCCESS
    else { return types }
    defer { IOObjectRelease(children) }
    while let child = next(children) {
      defer { IOObjectRelease(child) }
      guard let logical = property(child, "logical-cpu-id") as? NSNumber,
        let cluster = text(property(child, "cluster-type")),
        cluster == "P" || cluster == "E"
      else { continue }
      for index in 0..<count {
        let slot = (info + index * stride).withMemoryRebound(
          to: processor_basic_info_data_t.self, capacity: 1
        ) { $0.pointee.slot_num }
        if slot == logical.int32Value {
          types[index] = cluster == "P" ? "performance" : "efficiency"
        }
      }
    }
    #endif
    return types
  }

  private func processCounts() -> [String: Any] {
    var processes: Int?
    var threads: Int?
    var complete = false
    var set: processor_set_name_t = 0
    if processor_set_default(host, &set) == KERN_SUCCESS {
      defer { mach_port_deallocate(mach_task_self_, set) }
      var load = processor_set_load_info_data_t()
      var count = mach_msg_type_number_t(
        MemoryLayout<processor_set_load_info_data_t>.stride / MemoryLayout<integer_t>.stride)
      let status = withUnsafeMutablePointer(to: &load) { pointer in
        pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
          processor_set_statistics(set, PROCESSOR_SET_LOAD_INFO, $0, &count)
        }
      }
      if status == KERN_SUCCESS && load.task_count >= 0 && load.thread_count >= 0 {
        processes = Int(load.task_count)
        threads = Int(load.thread_count)
        complete = true
      }
    }
    var readable = 0
    let required = proc_listallpids(nil, 0)
    if required > 0 && required < 1_000_000 {
      let capacity = Int(required) + 256
      var pids = [pid_t](repeating: 0, count: capacity)
      let found = pids.withUnsafeMutableBytes { proc_listallpids($0.baseAddress, Int32($0.count)) }
      if found > 0 && Int(found) < capacity {
        if processes == nil { processes = Int(found) }
        var partialThreads = 0
        for pid in pids.prefix(Int(found)) {
          var task = proc_taskinfo()
          let size = Int32(MemoryLayout<proc_taskinfo>.stride)
          if proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &task, size) == size {
            readable += 1
            partialThreads += Int(task.pti_threadnum)
          }
        }
        if !complete && readable > 0 { threads = partialThreads }
      }
    }
    return [
      "processes": processes as Any? ?? NSNull(),
      "threads": threads as Any? ?? NSNull(),
      "threads_complete": complete,
      "processes_readable": readable,
    ]
  }

  private func memory() -> [String: Any] {
    var stats = vm_statistics64()
    var count = mach_msg_type_number_t(
      MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride)
    var pageSize: vm_size_t = 0
    let status = withUnsafeMutablePointer(to: &stats) { pointer in
      pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
        host_statistics64(host, HOST_VM_INFO64, $0, &count)
      }
    }
    let available = status == KERN_SUCCESS && host_page_size(host, &pageSize) == KERN_SUCCESS
    var physical: UInt64 = 0
    let havePhysical = readSysctl("hw.memsize", into: &physical)
    var swap = xsw_usage()
    let haveSwap = readSysctl("vm.swapusage", into: &swap)
    var pressure: Int32 = 0
    let havePressure = readSysctl("kern.memorystatus_vm_pressure_level", into: &pressure)
      && [1, 2, 4].contains(pressure)
    var result: [String: Any] = [
      "physical": havePhysical ? physical as Any : NSNull(),
      "swap_used": haveSwap ? swap.xsu_used as Any : NSNull(),
      "swap_total": haveSwap ? swap.xsu_total as Any : NSNull(),
      "pressure": havePressure ? pressure as Any : NSNull(),
    ]
    let pages: [String: natural_t] = [
      "free": stats.free_count, "active": stats.active_count,
      "inactive": stats.inactive_count, "speculative": stats.speculative_count,
      "wired": stats.wire_count, "compressed": stats.compressor_page_count,
      "purgeable": stats.purgeable_count, "file_backed": stats.external_page_count,
      "anonymous": stats.internal_page_count,
    ]
    for (key, value) in pages {
      result[key] = available ? UInt64(value) * UInt64(pageSize) as Any : NSNull()
    }
    return result
  }

  private func disks() -> [String: Any] {
    let keys = ["Bytes (Read)", "Bytes (Write)", "Operations (Read)", "Operations (Write)"]
    let names = ["read_bytes", "write_bytes", "read_ops", "write_ops"]
    var totals = [UInt64](repeating: 0, count: keys.count)
    var complete = [Bool](repeating: true, count: keys.count)
    var devices: [String] = []
    var anyMetric = false
    forEachService("IOBlockStorageDriver") { driver in
      guard !isVirtualStorage(driver), let name = wholeDiskName(driver),
        !devices.contains(name) else { return }
      devices.append(name)
      let stats = property(driver, "Statistics") as? [String: Any]
      for index in keys.indices {
        guard let number = stats?[keys[index]] as? NSNumber, number.int64Value >= 0 else {
          complete[index] = false
          continue
        }
        let (sum, overflow) = totals[index].addingReportingOverflow(number.uint64Value)
        if overflow { complete[index] = false } else {
          totals[index] = sum
          anyMetric = true
        }
      }
    }
    var result: [String: Any] = ["devices": devices.sorted(), "available": !devices.isEmpty && anyMetric]
    for index in names.indices {
      result[names[index]] = !devices.isEmpty && complete[index] ? totals[index] as Any : NSNull()
    }
    return result
  }

  private func isVirtualStorage(_ driver: io_registry_entry_t) -> Bool {
    var current = driver
    IOObjectRetain(current)
    defer { if current != 0 { IOObjectRelease(current) } }
    for _ in 0..<16 {
      if let properties = property(current, "Protocol Characteristics") as? [String: Any],
        let interconnect = text(properties["Physical Interconnect"]),
        interconnect.contains("Virtual") || interconnect.contains("Disk Image") { return true }
      if IOObjectConformsTo(current, "IOHDIXHDDrive") != 0
        || IOObjectConformsTo(current, "IOHDIXHDDriveInKernel") != 0 { return true }
      var parent: io_registry_entry_t = 0
      let status = IORegistryEntryGetParentEntry(current, kIOServicePlane, &parent)
      IOObjectRelease(current)
      current = status == KERN_SUCCESS ? parent : 0
      if current == 0 { break }
    }
    return false
  }

  private func wholeDiskName(_ driver: io_registry_entry_t) -> String? {
    var children: io_iterator_t = 0
    guard IORegistryEntryGetChildIterator(driver, kIOServicePlane, &children) == KERN_SUCCESS
    else { return nil }
    defer { IOObjectRelease(children) }
    while let child = next(children) {
      defer { IOObjectRelease(child) }
      if IOObjectConformsTo(child, "IOMedia") != 0,
        property(child, "Whole") as? Bool == true,
        let name = text(property(child, "BSD Name")) { return name }
    }
    return nil
  }

  private func network() -> [String: Any] {
    var addresses: UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&addresses) == 0, let first = addresses else {
      return ["interfaces": [], "available": false]
    }
    defer { freeifaddrs(first) }
    let socketFD = socket(AF_INET, SOCK_DGRAM, 0)
    defer { if socketFD >= 0 { close(socketFD) } }
    var seen = Set<String>()
    var interfaces: [[String: Any]] = []
    var complete = true
    var current: UnsafeMutablePointer<ifaddrs>? = first
    while let pointer = current {
      let item = pointer.pointee
      current = item.ifa_next
      guard item.ifa_addr?.pointee.sa_family == UInt8(AF_LINK) else { continue }
      let name = String(cString: item.ifa_name)
      let flags = Int32(item.ifa_flags)
      guard name.range(of: "^en[0-9]+$", options: .regularExpression) != nil,
        flags & (IFF_UP | IFF_RUNNING) == (IFF_UP | IFF_RUNNING),
        flags & (IFF_LOOPBACK | IFF_POINTOPOINT) == 0, seen.insert(name).inserted,
        interfaceActive(socketFD, name: name) else { continue }
      // NET_RT_IFLIST2/getifaddrs byte totals truncate on some Intel macOS releases.
      // The interface MIB supplies the real 64-bit counters; never fall back.
      var mib: [Int32] = [CTL_NET, PF_LINK, NETLINK_GENERIC, IFMIB_IFDATA,
        Int32(if_nametoindex(item.ifa_name)), IFDATA_GENERAL]
      var data = ifmibdata()
      var size = MemoryLayout<ifmibdata>.stride
      let status = sysctl(&mib, UInt32(mib.count), &data, &size, nil, 0)
      guard status == 0 && size >= MemoryLayout<ifmibdata>.stride else {
        complete = false
        continue
      }
      interfaces.append([
        "name": name,
        "rx_bytes": data.ifmd_data.ifi_ibytes, "tx_bytes": data.ifmd_data.ifi_obytes,
        "rx_packets": data.ifmd_data.ifi_ipackets, "tx_packets": data.ifmd_data.ifi_opackets,
      ])
    }
    return ["interfaces": interfaces.sorted { ($0["name"] as! String) < ($1["name"] as! String) },
      "available": complete]
  }

  private func interfaceActive(_ socketFD: Int32, name: String) -> Bool {
    guard socketFD >= 0 else { return true }
    var request = ifmediareq()
    withUnsafeMutableBytes(of: &request.ifm_name) { buffer in
      let bytes = Array(name.utf8.prefix(buffer.count - 1)) + [0]
      buffer.copyBytes(from: bytes)
    }
    // Swift cannot import SIOCGIFMEDIA's struct-valued _IOWR macro. Encode it
    // exactly as Darwin sys/ioccom.h: _IOWR('i', 56, struct ifmediareq).
    let command = UInt(IOC_INOUT) | ((UInt(MemoryLayout<ifmediareq>.stride) & UInt(IOCPARM_MASK)) << 16)
      | (UInt(0x69) << 8) | 56
    if ioctl(socketFD, command, &request) == 0 && request.ifm_status & IFM_AVALID != 0 {
      return request.ifm_status & IFM_ACTIVE != 0
    }
    return true
  }

  private func gpus() -> [[String: Any]] {
    var result: [[String: Any]] = []
    forEachService("IOAccelerator") { accelerator in
      let stats = property(accelerator, "PerformanceStatistics") as? [String: Any]
      var usage: Double?
      for key in ["Device Utilization %", "Device Utilization %%", "Device Utilization % at cur p-state"] {
        if let number = stats?[key] as? NSNumber, number.doubleValue.isFinite,
          (0...100).contains(number.doubleValue) { usage = number.doubleValue; break }
      }
      result.append(["name": gpuName(accelerator), "utilization": usage as Any? ?? NSNull()])
    }
    return result
  }

  private func gpuName(_ accelerator: io_registry_entry_t) -> String {
    if let model = text(property(accelerator, "model")) { return model }
    var current = accelerator
    IOObjectRetain(current)
    defer { if current != 0 { IOObjectRelease(current) } }
    for _ in 0..<16 {
      if IOObjectConformsTo(current, "IOPCIDevice") != 0,
        let model = text(property(current, "model")) { return model }
      var parent: io_registry_entry_t = 0
      let status = IORegistryEntryGetParentEntry(current, kIOServicePlane, &parent)
      IOObjectRelease(current)
      current = status == KERN_SUCCESS ? parent : 0
      if current == 0 { break }
    }
    var name = [CChar](repeating: 0, count: 128)
    return IORegistryEntryGetName(accelerator, &name) == KERN_SUCCESS
      ? String(cString: name) : "Unknown GPU"
  }

  private func property(_ entry: io_registry_entry_t, _ key: String) -> Any? {
    IORegistryEntryCreateCFProperty(entry, key as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue()
  }

  private func text(_ value: Any?) -> String? {
    if let string = value as? String { return string }
    if let data = value as? Data {
      return String(data: data, encoding: .utf8)?
        .trimmingCharacters(in: .controlCharacters.union(.whitespacesAndNewlines))
    }
    return nil
  }

  private func next(_ iterator: io_iterator_t) -> io_registry_entry_t? {
    let entry = IOIteratorNext(iterator)
    return entry == 0 ? nil : entry
  }

  private func forEachService(_ name: String, body: (io_registry_entry_t) -> Void) {
    guard let matching = IOServiceMatching(name) else { return }
    var iterator: io_iterator_t = 0
    guard IOServiceGetMatchingServices(0, matching, &iterator) == KERN_SUCCESS else { return }
    defer { IOObjectRelease(iterator) }
    while let entry = next(iterator) {
      body(entry)
      IOObjectRelease(entry)
    }
  }

  private func release(_ info: processor_info_array_t, count: mach_msg_type_number_t) {
    vm_deallocate(mach_task_self_, vm_address_t(UInt(bitPattern: info)),
      vm_size_t(Int(count) * MemoryLayout<integer_t>.stride))
  }

  private func readSysctl<T>(_ key: String, into value: inout T) -> Bool {
    var size = MemoryLayout<T>.stride
    return withUnsafeMutablePointer(to: &value) {
      sysctlbyname(key, $0, &size, nil, 0) == 0 && size == MemoryLayout<T>.stride
    }
  }

  private func sysctlString(_ key: String) -> String? {
    var size = 0
    guard sysctlbyname(key, nil, &size, nil, 0) == 0, size > 0 else { return nil }
    var buffer = [CChar](repeating: 0, count: size)
    guard sysctlbyname(key, &buffer, &size, nil, 0) == 0 else { return nil }
    return String(cString: buffer)
  }
}
