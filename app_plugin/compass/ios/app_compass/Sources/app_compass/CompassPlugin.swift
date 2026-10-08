import CoreLocation
import Flutter
import UIKit

public final class CompassPlugin: NSObject, FlutterPlugin, FlutterStreamHandler,
    CLLocationManagerDelegate
{
    private weak var registrar: FlutterPluginRegistrar?
    private var methodChannel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    private var eventSink: FlutterEventSink?
    private var manager: CLLocationManager?
    private var orientation = CLDeviceOrientation.portrait
    private var startedAt: Date?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = CompassPlugin()
        instance.registrar = registrar
        let methodChannel = FlutterMethodChannel(
            name: "app_compass", binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: "app_compass/events", binaryMessenger: registrar.messenger()
        )
        instance.methodChannel = methodChannel
        instance.eventChannel = eventChannel
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
        // Publishing enables Flutter's engine-detach cleanup callback.
        registrar.publish(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "refreshOrientation" else {
            result(FlutterMethodNotImplemented)
            return
        }
        refreshOrientation()
        result(nil)
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
        -> FlutterError?
    {
        stopHeading()
        eventSink = events
        guard CLLocationManager.headingAvailable() else {
            events(CompassHeading.unavailable(reason: "sensorNotFound"))
            return nil
        }
        orientation = currentOrientation()
        startHeading()
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stopHeading()
        eventSink = nil
        return nil
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        stopHeading()
        eventSink = nil
        eventChannel?.setStreamHandler(nil)
        methodChannel?.setMethodCallHandler(nil)
        eventChannel = nil
        methodChannel = nil
        self.registrar = nil
    }

    deinit {
        manager?.stopUpdatingHeading()
        manager?.delegate = nil
    }

    private func currentOrientation() -> CLDeviceOrientation {
        guard let interfaceOrientation = registrar?.viewController?.viewIfLoaded?.window?
            .windowScene?.interfaceOrientation, interfaceOrientation != .unknown
        else { return orientation }
        return CompassHeading.orientation(for: interfaceOrientation)
    }

    @discardableResult
    private func refreshOrientation() -> Bool {
        let nextOrientation = currentOrientation()
        guard nextOrientation != orientation else { return false }
        orientation = nextOrientation
        if manager != nil, eventSink != nil {
            // A new manager makes queued callbacks from the old reference identifiable.
            stopHeading()
            startHeading()
        }
        return true
    }

    private func startHeading() {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.headingOrientation = orientation
        manager.headingFilter = kCLHeadingFilterNone
        self.manager = manager
        startedAt = Date()
        manager.startUpdatingHeading()
    }

    private func stopHeading() {
        let previousManager = manager
        manager = nil
        startedAt = nil
        previousManager?.stopUpdatingHeading()
        previousManager?.delegate = nil
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard manager === self.manager, let eventSink else { return }
        guard !refreshOrientation() else { return }
        // Core Location can initially deliver a cached sample from before this reference/session.
        guard let startedAt, newHeading.timestamp >= startedAt else { return }
        eventSink(CompassHeading.event(
            magneticHeading: newHeading.magneticHeading,
            accuracy: newHeading.headingAccuracy
        ))
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard manager === self.manager, let eventSink else { return }
        stopHeading()
        eventSink(CompassHeading.unavailable(reason: "sensorFailure"))
    }

    public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        false
    }
}

enum CompassHeading {
    static func orientation(for orientation: UIInterfaceOrientation) -> CLDeviceOrientation {
        switch orientation {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeRight
        case .landscapeRight: return .landscapeLeft
        default: return .portrait
        }
    }

    static func event(magneticHeading: Double, accuracy: Double) -> [String: Any] {
        let valid = magneticHeading.isFinite && magneticHeading >= 0 && magneticHeading < 360
            && accuracy.isFinite && accuracy >= 0
        return [
            "status": valid && accuracy <= 20 ? "ready" : "calibrating",
            "magneticHeadingDegrees": valid ? magneticHeading as Any : NSNull(),
            "accuracyDegrees": valid ? accuracy as Any : NSNull(),
            "sensorAccuracy": NSNull(),
            "unavailableReason": NSNull(),
        ]
    }

    static func unavailable(reason: String) -> [String: Any] {
        [
            "status": "unavailable",
            "magneticHeadingDegrees": NSNull(),
            "accuracyDegrees": NSNull(),
            "sensorAccuracy": NSNull(),
            "unavailableReason": reason,
        ]
    }
}
