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
SWIFT

swiftc \
    -emit-module \
    -emit-object \
    -parse-as-library \
    -module-name FlutterMacOS \
    "$TMP_DIR/FlutterMacOS.swift" \
    -emit-module-path "$TMP_DIR/FlutterMacOS.swiftmodule" \
    -o "$TMP_DIR/FlutterMacOS.o"

run_source_dir() {
    local source_dir="$1"
    local binary="$TMP_DIR/$(basename "$source_dir")-metrics-smoke"
    local sources=("$source_dir"/*.swift)
    swiftc \
        -I "$TMP_DIR" \
        "$TMP_DIR/FlutterMacOS.o" \
        "${sources[@]}" \
        "$TMP_DIR/main.swift" \
        -framework Cocoa \
        -framework IOKit \
        -o "$binary"
    "$binary"
}

run_source_dir "$ROOT/macos/Classes"
run_source_dir "$ROOT/macos/app_system_metrics_macos/Sources/app_system_metrics_macos"
