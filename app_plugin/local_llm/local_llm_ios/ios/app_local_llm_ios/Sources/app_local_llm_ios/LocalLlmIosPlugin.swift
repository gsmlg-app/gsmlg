import Flutter
import UIKit
import os

public class LocalLlmIosPlugin: NSObject, FlutterPlugin {
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "app_local_llm_ios/service",
            binaryMessenger: registrar.messenger()
        )
        let instance = LocalLlmIosPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "prepareTitleModel":
            guard ProcessInfo.processInfo.physicalMemory >= 6 * 1024 * 1024 * 1024,
                  os_proc_available_memory() >= 2 * 1024 * 1024 * 1024 else {
                result(FlutterError(code: "title_model_unavailable", message: "Insufficient available memory for optional title inference", details: nil))
                return
            }
            let path = Bundle.main.bundlePath + "/Frameworks/App.framework/flutter_assets/assets/models/conversation_title/MiniCPM5-1B-Q4_K_M.gguf"
            guard FileManager.default.fileExists(atPath: path) else {
                result(FlutterError(code: "title_model_missing", message: "Required bundled title model is missing", details: nil))
                return
            }
            result(path)
        case "startService":
            startService(call: call, result: result)
        case "stopService":
            stopService()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startService(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if backgroundTask != .invalid {
            result(nil)
            return
        }

        let arguments = call.arguments as? [String: Any]
        let title = arguments?["title"] as? String ?? "Local LLM"
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: title) { [weak self] in
            self?.stopService()
        }

        if backgroundTask == .invalid {
            result(FlutterError(
                code: "background_task_start_failed",
                message: "Failed to start local LLM background task.",
                details: nil
            ))
            return
        }

        result(nil)
    }

    private func stopService() {
        guard backgroundTask != .invalid else {
            return
        }

        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
}
