import Cocoa
import FlutterMacOS

public class SystemMetricsPlugin: NSObject, FlutterPlugin {
  private let metricsCollector = MacOSSystemMetricsCollector()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "app_system_metrics",
      binaryMessenger: registrar.messenger
    )
    let instance = SystemMetricsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getData":
      do {
        let data = try getData()
        result(data)
      } catch {
        result(
          FlutterError(
            code: "ERROR",
            message: "Failed to get data: \(error.localizedDescription)",
            details: nil
          ))
      }
    case "refresh":
      metricsCollector.reset()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getData() throws -> [String: Any] {
    let processInfo = ProcessInfo.processInfo
    let metrics = metricsCollector.snapshot()
    var additionalData: [String: Any] = [
      "hostName": processInfo.hostName,
      "operatingSystemVersion":
        "\(processInfo.operatingSystemVersion.majorVersion).\(processInfo.operatingSystemVersion.minorVersion).\(processInfo.operatingSystemVersion.patchVersion)",
      "operatingSystemVersionString": processInfo.operatingSystemVersionString,
      "processorCount": processInfo.processorCount,
      "activeProcessorCount": processInfo.activeProcessorCount,
      "physicalMemory": processInfo.physicalMemory,
      "memoryUsedBytes": metrics.memoryUsedBytes,
      "memoryTotalBytes": metrics.memoryTotalBytes,
      "gpuMetricsSource": metrics.gpuMetricsSource,
    ]
    if let gpuModel = metrics.gpuModel {
      additionalData["gpuModel"] = gpuModel
    }
    if let gpuCoreCount = metrics.gpuCoreCount {
      additionalData["gpuCoreCount"] = gpuCoreCount
    }

    return [
      "platform": "macos",
      "timestamp": ISO8601DateFormatter().string(from: Date()),
      "cpuUsage": metrics.cpuUsage,
      "gpuUsage": metrics.gpuUsage,
      "npuUsage": 0.0,
      "memoryUsage": metrics.memoryUsage,
      "additionalData": additionalData,
    ]
  }
}
