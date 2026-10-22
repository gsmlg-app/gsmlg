import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func application(_ application: NSApplication, open urls: [URL]) {
    EditorDocumentBridge.shared.receive(urls.filter { $0.isFileURL })
    let otherURLs = urls.filter { !$0.isFileURL }
    if !otherURLs.isEmpty { super.application(application, open: otherURLs) }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}

/// Original document URLs remain security scoped for each coordinated operation.
final class EditorDocumentBridge {
  static let shared = EditorDocumentBridge()
  private let maximumBytes = 16 * 1024 * 1024
  private var channel: FlutterMethodChannel?
  private var ready = false
  private var pending: [String] = []
  private var locations: [String: URL] = [:]
  private let io = DispatchQueue(label: "org.gsmlg.editor.documents")

  func bind(_ messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "gsmlg/editor", binaryMessenger: messenger)
    self.channel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
  }

  func receive(_ urls: [URL]) {
    let files = urls.filter { $0.isFileURL }
    for url in files { locations[url.absoluteString] = url }
    let uris = files.map { $0.absoluteString }
    guard !uris.isEmpty else { return }
    if ready {
      channel?.invokeMethod("openFiles", arguments: uris)
    } else {
      pending.append(contentsOf: uris)
    }
    NSApp.activate(ignoringOtherApps: true)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "ready":
      ready = true
      let initial = pending
      pending.removeAll()
      result(initial)
    case "pickFile":
      let panel = NSOpenPanel()
      panel.canChooseDirectories = false
      panel.allowsMultipleSelection = false
      panel.begin { response in
        guard response == .OK, let url = panel.url else { result(nil); return }
        self.locations[url.absoluteString] = url
        self.read(url, result: result)
      }
    case "readFile":
      guard let url = documentURL(args) else {
        result(failure("read_failed")); return
      }
      read(url, result: result)
    case "writeFile":
      guard let url = documentURL(args), let bytes = args["bytes"] as? FlutterStandardTypedData else {
        result(failure("write_failed")); return
      }
      write(bytes.data, to: url, result: result)
    case "saveFileAs":
      guard let bytes = args["bytes"] as? FlutterStandardTypedData else {
        result(failure("write_failed")); return
      }
      let panel = NSSavePanel()
      panel.nameFieldStringValue = (args["name"] as? String) ?? "untitled.txt"
      panel.canCreateDirectories = true
      panel.begin { response in
        guard response == .OK, let url = panel.url else { result(nil); return }
        self.locations[url.absoluteString] = url
        self.write(bytes.data, to: url) { value in
          if value is FlutterError { result(value) } else {
            result(self.metadata(url))
          }
        }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func documentURL(_ args: [String: Any]) -> URL? {
    guard let uri = args["uri"] as? String else { return nil }
    let url = locations[uri] ?? URL(string: uri)
    return url?.isFileURL == true ? url : nil
  }

  private func metadata(_ url: URL) -> [String: Any] {
    let scoped = url.startAccessingSecurityScopedResource()
    defer { if scoped { url.stopAccessingSecurityScopedResource() } }
    return ["uri": url.absoluteString, "name": url.lastPathComponent,
            "writable": FileManager.default.isWritableFile(atPath: url.path)]
  }

  private func read(_ url: URL, result: @escaping FlutterResult) {
    io.async { self.readCoordinated(url, result: result) }
  }

  private func readCoordinated(_ url: URL, result: @escaping FlutterResult) {
    let scoped = url.startAccessingSecurityScopedResource()
    defer { if scoped { url.stopAccessingSecurityScopedResource() } }
    var coordinationError: NSError?
    var response: Any = failure("read_failed")
    NSFileCoordinator().coordinate(readingItemAt: url, options: [], error: &coordinationError) { source in
      do {
        let handle = try FileHandle(forReadingFrom: source)
        defer { try? handle.close() }
        let data = try handle.read(upToCount: self.maximumBytes + 1) ?? Data()
        guard data.count <= self.maximumBytes else {
          response = self.failure("too_large"); return
        }
        var value = self.metadata(url)
        value["bytes"] = FlutterStandardTypedData(bytes: data)
        response = value
      } catch { response = self.failure("read_failed") }
    }
    let value = coordinationError == nil ? response : failure("read_failed")
    DispatchQueue.main.async { result(value) }
  }

  private func write(_ data: Data, to url: URL, result: @escaping FlutterResult) {
    io.async { self.writeCoordinated(data, to: url, result: result) }
  }

  private func writeCoordinated(_ data: Data, to url: URL, result: @escaping FlutterResult) {
    let scoped = url.startAccessingSecurityScopedResource()
    defer { if scoped { url.stopAccessingSecurityScopedResource() } }
    var coordinationError: NSError?
    var response: Any = failure("write_failed")
    NSFileCoordinator().coordinate(writingItemAt: url, options: .forReplacing, error: &coordinationError) { destination in
      let target = destination.resolvingSymlinksInPath()
      // Atomic replacement can succeed even after a document becomes read-only.
      let files = FileManager.default
      if files.fileExists(atPath: target.path) && !files.isWritableFile(atPath: target.path) {
        response = self.failure("write_failed")
        return
      }
      do {
        try data.write(to: target, options: .atomic)
        response = true
      } catch { response = self.failure("write_failed") }
    }
    let value = coordinationError == nil ? response : failure("write_failed")
    DispatchQueue.main.async { result(value) }
  }

  private func failure(_ code: String) -> FlutterError {
    FlutterError(code: code, message: "Document operation failed.", details: nil)
  }
}
