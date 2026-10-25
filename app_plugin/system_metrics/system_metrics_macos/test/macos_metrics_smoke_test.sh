#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

cat >"$TMP_DIR/FlutterMacOS.swift" <<'SWIFT'
public protocol FlutterBinaryMessenger {}

public protocol FlutterPlugin {
    static func register(with registrar: FlutterPluginRegistrar)
}

public protocol FlutterPluginRegistrar {
    var messenger: FlutterBinaryMessenger { get }
    func addMethodCallDelegate(_ delegate: Any, channel: FlutterMethodChannel)
}

public typealias FlutterResult = (Any?) -> Void

public final class FlutterMethodCall {
    public let method: String
    public let arguments: Any?

    public init(method: String, arguments: Any? = nil) {
        self.method = method
        self.arguments = arguments
    }
}

public final class FlutterMethodChannel {
    public init(name: String, binaryMessenger: FlutterBinaryMessenger) {}
}

public final class FlutterError: Error {
    public let code: String
    public let message: String?
    public let details: Any?

    public init(code: String, message: String?, details: Any?) {
        self.code = code
        self.message = message
        self.details = details
    }
}

public let FlutterMethodNotImplemented = "FlutterMethodNotImplemented"
SWIFT

cat >"$TMP_DIR/main.swift" <<'SWIFT'
import Darwin
import Foundation
import FlutterMacOS

func fail(_ message: String) -> Never {
    fputs("\(message)\n", stderr)
    exit(1)
}

let plugin = SystemMetricsPlugin()
var payload: Any?

plugin.handle(FlutterMethodCall(method: "getData")) { result in
    payload = result
}

guard let data = payload as? [String: Any] else {
    fail("getData did not return a dictionary: \(String(describing: payload))")
}

for key in ["cpuUsage", "gpuUsage", "memoryUsage"] {
    guard let value = data[key] as? Double else {
        fail("missing numeric \(key) in getData payload: \(data)")
    }
    guard value.isFinite && value >= 0.0 && value <= 100.0 else {
        fail("\(key) is outside 0...100: \(value)")
    }
}

guard data["platform"] as? String == "macos" else {
    fail("platform should be macos: \(data)")
}

func activityData() -> [String: Any] {
    var response: Any?
    plugin.handle(FlutterMethodCall(method: "getActivityData")) { value in
        guard Thread.isMainThread else { fail("activity result must return on main thread") }
        response = value
    }
    let deadline = Date().addingTimeInterval(10)
    while response == nil && Date() < deadline {
        _ = RunLoop.main.run(mode: .default, before: Date().addingTimeInterval(0.01))
    }
    guard let activity = response as? [String: Any] else {
        fail("getActivityData did not return a dictionary: \(String(describing: response))")
    }
    guard JSONSerialization.isValidJSONObject(activity) else { fail("invalid activity JSON") }
    return activity
}

let first = activityData()
Thread.sleep(forTimeInterval: 0.1)
let activity = activityData()
guard let before = first["monotonic_ms"] as? Int64,
      let after = activity["monotonic_ms"] as? Int64, after > before else {
    fail("monotonic clock did not advance")
}
guard let cores = activity["cores"] as? [[String: Any]],
      cores.count == ProcessInfo.processInfo.processorCount,
      Set(cores.compactMap { $0["id"] as? Int }).count == cores.count else {
    fail("CPU cores should match host logical processors")
}
for core in cores {
    for key in ["user", "system", "nice", "idle"] {
        guard let value = core[key] as? UInt64, value <= UInt64(UInt32.max) else {
            fail("invalid unsigned CPU tick counter: \(core)")
        }
    }
    guard core["type"] is NSNull || ["performance", "efficiency"].contains(core["type"] as? String ?? "")
    else { fail("unexpected core type") }
}
#if arch(arm64)
func sysctlInt(_ key: String) -> Int32? {
    var value: Int32 = 0
    var size = MemoryLayout<Int32>.stride
    return sysctlbyname(key, &value, &size, nil, 0) == 0 ? value : nil
}
if let performance = sysctlInt("hw.perflevel0.logicalcpu"),
   let efficiency = sysctlInt("hw.perflevel1.logicalcpu") {
    guard cores.filter({ $0["type"] as? String == "performance" }).count == Int(performance),
          cores.filter({ $0["type"] as? String == "efficiency" }).count == Int(efficiency) else {
        fail("P/E core mapping does not match host performance-level counts")
    }
}
#else
guard cores.allSatisfy({ $0["type"] is NSNull }) else { fail("Intel cores must have generic type") }
#endif
guard let memory = activity["memory"] as? [String: Any],
      let physical = memory["physical"] as? UInt64,
      physical == ProcessInfo.processInfo.physicalMemory,
      memory["active"] is UInt64, memory["wired"] is UInt64,
      memory["compressed"] is UInt64 else { fail("memory counters missing") }
guard let disk = activity["disk"] as? [String: Any],
      let devices = disk["devices"] as? [String],
      devices.count == Set(devices).count,
      disk["available"] is Bool else { fail("disk contract invalid") }
guard let network = activity["network"] as? [String: Any],
      let interfaces = network["interfaces"] as? [[String: Any]],
      network["available"] is Bool else { fail("network contract invalid") }
for interface in interfaces {
    guard (interface["name"] as? String)?.hasPrefix("en") == true,
          interface["rx_bytes"] is UInt64, interface["tx_bytes"] is UInt64 else {
        fail("network counters must be 64-bit physical interface counters")
    }
}
guard let gpus = activity["gpu"] as? [[String: Any]],
      activity["processes"] is Int || activity["processes"] is NSNull,
      activity["threads"] is Int || activity["threads"] is NSNull,
      activity["threads_complete"] is Bool else { fail("activity counts/GPU contract invalid") }
for gpu in gpus {
    guard gpu["name"] is String else { fail("GPU name missing") }
    if let usage = gpu["utilization"] as? Double {
        guard usage.isFinite && (0...100).contains(usage) else { fail("invalid GPU utilization") }
    } else if !(gpu["utilization"] is NSNull) { fail("unavailable GPU usage must be null") }
}
let summary: [String: Any] = [
    "architecture": activity["architecture"]!, "cores": cores.count,
    "performance": cores.filter { $0["type"] as? String == "performance" }.count,
    "efficiency": cores.filter { $0["type"] as? String == "efficiency" }.count,
    "memory_bytes": physical, "disks": devices,
    "network_interfaces": interfaces.compactMap { $0["name"] as? String },
    "gpus": gpus, "processes": activity["processes"]!,
    "threads": activity["threads"]!, "threads_complete": activity["threads_complete"]!,
]
let summaryData = try JSONSerialization.data(withJSONObject: summary, options: [.sortedKeys])
print(String(data: summaryData, encoding: .utf8)!)
SWIFT

compile_source_dir() {
    local source_dir="$1"
    local architecture="$2"
    local minimum="10.14"
    if [[ "$architecture" == "arm64" ]]; then minimum="11.0"; fi
    local target="${architecture}-apple-macosx${minimum}"
    local module_dir="$TMP_DIR/$architecture"
    mkdir -p "$module_dir"
    swiftc -target "$target" \
        -emit-module -emit-object -parse-as-library -module-name FlutterMacOS \
        "$TMP_DIR/FlutterMacOS.swift" \
        -emit-module-path "$module_dir/FlutterMacOS.swiftmodule" \
        -o "$module_dir/FlutterMacOS.o"
    local binary="$module_dir/$(basename "$source_dir")-metrics-smoke"
    local sources=("$source_dir"/*.swift)
    swiftc -target "$target" -warnings-as-errors \
        -I "$module_dir" "$module_dir/FlutterMacOS.o" \
        "${sources[@]}" "$TMP_DIR/main.swift" \
        -framework Cocoa -framework IOKit -o "$binary"
    if [[ "$architecture" == "$(uname -m)" ]]; then
        "$binary"
    else
        printf 'Cross-compiled %s (%s)\n' "$architecture" "$(basename "$source_dir")"
    fi
}

for architecture in arm64 x86_64; do
    compile_source_dir "$ROOT/macos/Classes" "$architecture"
    compile_source_dir "$ROOT/macos/app_system_metrics_macos/Sources/app_system_metrics_macos" "$architecture"
done
cmp "$ROOT/macos/Classes/ActivityMonitorCollector.swift" \
    "$ROOT/macos/app_system_metrics_macos/Sources/app_system_metrics_macos/ActivityMonitorCollector.swift"
cmp "$ROOT/macos/Classes/SystemMetricsPlugin.swift" \
    "$ROOT/macos/app_system_metrics_macos/Sources/app_system_metrics_macos/SystemMetricsPlugin.swift"
