import Cocoa
import FlutterMacOS
import ImageIO
import UniformTypeIdentifiers

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

/// Reads copied files or images from macOS NSPasteboard for chat attachments.
final class ClipboardBridge {
  static let shared = ClipboardBridge()
  private let maximumBytes = 25 * 1024 * 1024
  private var channel: FlutterMethodChannel?

  func bind(_ messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "gsmlg/clipboard", binaryMessenger: messenger)
    self.channel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { result(nil); return }
      switch call.method {
      case "readAttachments":
        result(self.readAttachments())
      case "normalizeImage":
        let args = call.arguments as? [String: Any] ?? [:]
        guard let typed = args["bytes"] as? FlutterStandardTypedData else {
          result(nil); return
        }
        let maxDimension = (args["maxDimension"] as? NSNumber)?.intValue ?? 1568
        let quality = ((args["quality"] as? NSNumber)?.doubleValue ?? 82.0) / 100.0
        let maxBytes = (args["maxBytes"] as? NSNumber)?.intValue ?? (512 * 1024)
        DispatchQueue.global(qos: .userInitiated).async {
          let normalized = self.normalizeImageData(
            typed.data,
            maxDimension: maxDimension,
            quality: quality,
            maxBytes: maxBytes
          )
          DispatchQueue.main.async {
            if let normalized {
              result([
                "bytes": FlutterStandardTypedData(bytes: normalized.data),
                "mimeType": normalized.mimeType,
                "extension": normalized.ext,
              ])
            } else {
              result(nil)
            }
          }
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func readAttachments() -> [[String: Any]] {
    let pasteboard = NSPasteboard.general
    var items: [[String: Any]] = []

    // 1. Check file URLs copied from Finder or other apps.
    if let urls = pasteboard.readObjects(
      forClasses: [NSURL.self],
      options: [.urlReadingFileURLsOnly: true]
    ) as? [URL], !urls.isEmpty {
      for url in urls where url.isFileURL && !url.hasDirectoryPath {
        guard let values = try? url.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey]),
              values.isRegularFile == true,
              (values.fileSize ?? 0) <= maximumBytes,
              let data = try? Data(contentsOf: url),
              data.count <= maximumBytes else { continue }
        let mimeType = UTType(filenameExtension: url.pathExtension)?.preferredMIMEType
        var entry: [String: Any] = [
          "name": url.lastPathComponent,
          "bytes": FlutterStandardTypedData(bytes: data),
          "sizeBytes": data.count,
        ]
        if let mimeType { entry["mimeType"] = mimeType }
        items.append(entry)
      }
      if !items.isEmpty { return items }
    }

    // 2. Check raw image data (screenshots, browser/Preview Copy Image).
    let timestamp = Int(Date().timeIntervalSince1970 * 1000)
    if let pngData = pasteboard.data(forType: .png), pngData.count <= maximumBytes {
      if let normalized = normalizeImageData(pngData) {
        return [[
          "name": "pasted_image_\(timestamp).\(normalized.ext)",
          "mimeType": normalized.mimeType,
          "bytes": FlutterStandardTypedData(bytes: normalized.data),
          "sizeBytes": normalized.data.count,
        ]]
      }
      return [[
        "name": "pasted_image_\(timestamp).png",
        "mimeType": "image/png",
        "bytes": FlutterStandardTypedData(bytes: pngData),
        "sizeBytes": pngData.count,
      ]]
    }
    let jpegType = NSPasteboard.PasteboardType("public.jpeg")
    if let jpegData = pasteboard.data(forType: jpegType), jpegData.count <= maximumBytes {
      if let normalized = normalizeImageData(jpegData) {
        return [[
          "name": "pasted_image_\(timestamp).\(normalized.ext)",
          "mimeType": normalized.mimeType,
          "bytes": FlutterStandardTypedData(bytes: normalized.data),
          "sizeBytes": normalized.data.count,
        ]]
      }
      return [[
        "name": "pasted_image_\(timestamp).jpg",
        "mimeType": "image/jpeg",
        "bytes": FlutterStandardTypedData(bytes: jpegData),
        "sizeBytes": jpegData.count,
      ]]
    }
    if let image = NSImage(pasteboard: pasteboard),
       let tiff = image.tiffRepresentation,
       let rep = NSBitmapImageRep(data: tiff),
       let pngData = rep.representation(using: .png, properties: [:]),
       pngData.count <= maximumBytes {
      if let normalized = normalizeImageData(pngData) {
        return [[
          "name": "pasted_image_\(timestamp).\(normalized.ext)",
          "mimeType": normalized.mimeType,
          "bytes": FlutterStandardTypedData(bytes: normalized.data),
          "sizeBytes": normalized.data.count,
        ]]
      }
      return [[
        "name": "pasted_image_\(timestamp).png",
        "mimeType": "image/png",
        "bytes": FlutterStandardTypedData(bytes: pngData),
        "sizeBytes": pngData.count,
      ]]
    }

    return items
  }

  /// Downscales oversized images and encodes them as JPEG so remote multimodal
  /// LLM requests stay fast and well under proxy / provider size limits.
  private func normalizeImageData(
    _ data: Data,
    maxDimension: Int = 1568,
    quality: Double = 0.82,
    maxBytes: Int = 512 * 1024
  ) -> (data: Data, mimeType: String, ext: String)? {
    guard let source = CGImageSourceCreateWithData(data as CFData, nil),
          let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
      return nil
    }
    let width = cgImage.width
    let height = cgImage.height
    guard width > 0, height > 0 else { return nil }

    let longest = max(width, height)
    if data.count <= maxBytes && longest <= maxDimension {
      return nil
    }

    let scale = longest > maxDimension ? Double(maxDimension) / Double(longest) : 1.0
    let targetWidth = max(1, Int((Double(width) * scale).rounded()))
    let targetHeight = max(1, Int((Double(height) * scale).rounded()))

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.noneSkipLast.rawValue
    guard let context = CGContext(
      data: nil,
      width: targetWidth,
      height: targetHeight,
      bitsPerComponent: 8,
      bytesPerRow: 0,
      space: colorSpace,
      bitmapInfo: bitmapInfo
    ) else {
      return nil
    }
    context.interpolationQuality = .high
    // Fill white so transparent PNGs do not render with black backgrounds in JPEG.
    context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    context.fill(CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight))
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight))

    guard let rendered = context.makeImage() else { return nil }
    let rep = NSBitmapImageRep(cgImage: rendered)
    guard let jpegData = rep.representation(
      using: .jpeg,
      properties: [.compressionFactor: NSNumber(value: quality)]
    ), jpegData.count < data.count else {
      return nil
    }
    return (jpegData, "image/jpeg", "jpg")
  }
}
