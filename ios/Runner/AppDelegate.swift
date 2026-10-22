import Flutter
import UIKit
import UniformTypeIdentifiers

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    EditorFileBridge.shared.bind(messenger: engineBridge.applicationRegistrar.messenger())
  }
}

/// Flutter owns engine/plugin lifecycle; this delegate adds only document delivery.
@objc class EditorSceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    EditorFileBridge.shared.open(connectionOptions.urlContexts.map(\.url))
  }

  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    let documents = URLContexts.filter { $0.url.isFileURL }
    EditorFileBridge.shared.open(documents.map(\.url))
    let otherURLs = URLContexts.subtracting(documents)
    if !otherURLs.isEmpty { super.scene(scene, openURLContexts: otherURLs) }
  }
}

private final class EditorFileBridge: NSObject, UIDocumentPickerDelegate {
  static let shared = EditorFileBridge()
  private static let maxBytes = 16 * 1024 * 1024
  private let io = DispatchQueue(label: "org.gsmlg.editor.files")
  private var channel: FlutterMethodChannel?
  private var ready = false
  private var pending: [String] = []
  // Preserve the URL objects carrying the provider's security-scoped access.
  private var documents: [String: URL] = [:]
  private var pickerResult: FlutterResult?
  private var exportDirectory: URL?

  func bind(messenger: FlutterBinaryMessenger) {
    channel?.setMethodCallHandler(nil)
    ready = false
    let channel = FlutterMethodChannel(name: "gsmlg/editor", binaryMessenger: messenger)
    self.channel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
  }

  func open(_ urls: [URL]) {
    let values = urls.filter(\.isFileURL).map { remember($0).absoluteString }
    guard !values.isEmpty else { return }
    if ready { channel?.invokeMethod("openFiles", arguments: values) }
    else { pending.append(contentsOf: values) }
  }

  private func remember(_ url: URL) -> URL {
    if let existing = documents[url.absoluteString] { return existing }
    documents[url.absoluteString] = url
    return url
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "ready":
      ready = true
      let files = pending
      pending.removeAll()
      result(files)
    case "pickFile":
      presentPicker(result: result, name: nil, data: nil)
    case "saveFileAs":
      guard let bytes = args["bytes"] as? FlutterStandardTypedData else {
        result(failure("write_failed")); return
      }
      presentPicker(result: result, name: args["name"] as? String ?? "untitled.txt", data: bytes.data)
    case "readFile", "writeFile":
      let writing = call.method == "writeFile"
      guard let value = args["uri"] as? String, let parsed = URL(string: value), parsed.isFileURL else {
        result(failure(writing ? "write_failed" : "read_failed")); return
      }
      let url = remember(parsed)
      if writing {
        guard let bytes = args["bytes"] as? FlutterStandardTypedData else {
          result(failure("write_failed")); return
        }
        perform(result: result, code: "write_failed") {
          try self.write(url, data: bytes.data)
          return true
        }
      } else {
        perform(result: result, code: "read_failed") { try self.read(url) }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func presentPicker(result: @escaping FlutterResult, name: String?, data: Data?) {
    let code = data == nil ? "read_failed" : "write_failed"
    guard pickerResult == nil, let presenter = presenter() else {
      result(failure(code)); return
    }
    let picker: UIDocumentPickerViewController
    if let data = data {
      do {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        exportDirectory = directory
        let filename = ((name ?? "untitled.txt") as NSString).lastPathComponent
        let file = directory.appendingPathComponent(filename.isEmpty ? "untitled.txt" : filename)
        try data.write(to: file, options: .atomic)
        picker = UIDocumentPickerViewController(forExporting: [file], asCopy: true)
      } catch {
        cleanExport()
        result(failure(code)); return
      }
    } else {
      picker = UIDocumentPickerViewController(forOpeningContentTypes: [.text, .sourceCode, .json, .xml, .data], asCopy: false)
    }
    picker.allowsMultipleSelection = false
    picker.delegate = self
    pickerResult = result
    presenter.present(picker, animated: true)
  }

  private func presenter() -> UIViewController? {
    let windows = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap(\.windows)
    var controller = windows.first(where: \.isKeyWindow)?.rootViewController
    while let presented = controller?.presentedViewController { controller = presented }
    return controller
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    let result = pickerResult
    pickerResult = nil
    cleanExport()
    result?(nil)
  }

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    guard let result = pickerResult else { return }
    pickerResult = nil
    let exporting = exportDirectory != nil
    guard let selected = urls.first else {
      cleanExport()
      result(nil); return
    }
    let url = remember(selected)
    // The picker has completed the copy; return the destination as the saved identity.
    cleanExport()
    if exporting {
      perform(result: result, code: "write_failed") { try self.metadata(url) }
    } else {
      perform(result: result, code: "read_failed") { try self.read(url) }
    }
  }

  private func cleanExport() {
    if let directory = exportDirectory { try? FileManager.default.removeItem(at: directory) }
    exportDirectory = nil
  }

  private func metadata(_ url: URL) throws -> [String: Any] {
    let accessing = url.startAccessingSecurityScopedResource()
    defer { if accessing { url.stopAccessingSecurityScopedResource() } }
    let values = try url.resourceValues(forKeys: [.nameKey, .isWritableKey])
    return ["uri": url.absoluteString, "name": values.name ?? url.lastPathComponent,
            "writable": values.isWritable ?? FileManager.default.isWritableFile(atPath: url.path)]
  }

  private enum ReadError: Error { case tooLarge, unavailable }

  private func read(_ url: URL) throws -> [String: Any] {
    let accessing = url.startAccessingSecurityScopedResource()
    defer { if accessing { url.stopAccessingSecurityScopedResource() } }
    var failure: Error?
    var value: [String: Any]?
    var coordinationError: NSError?
    NSFileCoordinator().coordinate(readingItemAt: url, options: [], error: &coordinationError) { coordinated in
      do {
        guard let stream = InputStream(url: coordinated) else { throw ReadError.unavailable }
        stream.open()
        defer { stream.close() }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 64 * 1024)
        while true {
          let count = stream.read(&buffer, maxLength: buffer.count)
          if count < 0 { throw stream.streamError ?? ReadError.unavailable }
          if count == 0 { break }
          if data.count + count > Self.maxBytes { throw ReadError.tooLarge }
          data.append(buffer, count: count)
        }
        var file = try self.metadata(url)
        file["bytes"] = FlutterStandardTypedData(bytes: data)
        value = file
      } catch { failure = error }
    }
    if let error = coordinationError { throw error }
    if let error = failure { throw error }
    guard let file = value else { throw ReadError.unavailable }
    return file
  }

  private func write(_ url: URL, data: Data) throws {
    let accessing = url.startAccessingSecurityScopedResource()
    defer { if accessing { url.stopAccessingSecurityScopedResource() } }
    var failure: Error?
    var coordinationError: NSError?
    NSFileCoordinator().coordinate(writingItemAt: url, options: .forReplacing, error: &coordinationError) { coordinated in
      do {
        let target = coordinated.resolvingSymlinksInPath()
        let files = FileManager.default
        if files.fileExists(atPath: target.path) && !files.isWritableFile(atPath: target.path) {
          throw CocoaError(.fileWriteNoPermission)
        }
        try data.write(to: target, options: .atomic)
      }
      catch { failure = error }
    }
    if let error = coordinationError { throw error }
    if let error = failure { throw error }
  }

  private func perform(result: @escaping FlutterResult, code: String, operation: @escaping () throws -> Any) {
    io.async {
      do {
        let value = try operation()
        DispatchQueue.main.async { result(value) }
      } catch ReadError.tooLarge {
        DispatchQueue.main.async { result(FlutterError(code: "too_large", message: "Files must be 16 MiB or smaller.", details: nil)) }
      } catch {
        DispatchQueue.main.async { result(self.failure(code)) }
      }
    }
  }

  private func failure(_ code: String) -> FlutterError {
    FlutterError(code: code, message: code == "write_failed" ? "Unable to write the document." : "Unable to read the document.", details: nil)
  }
}
