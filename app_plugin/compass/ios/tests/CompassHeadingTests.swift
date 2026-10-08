import CoreLocation
import Foundation
import UIKit

@main
enum CompassHeadingTests {
    static func main() {
        let orientations: [(UIInterfaceOrientation, CLDeviceOrientation)] = [
            (.portrait, .portrait),
            (.portraitUpsideDown, .portraitUpsideDown),
            (.landscapeLeft, .landscapeRight),
            (.landscapeRight, .landscapeLeft),
            (.unknown, .portrait),
        ]
        for (interfaceOrientation, expected) in orientations {
            precondition(CompassHeading.orientation(for: interfaceOrientation) == expected)
        }

        for accuracy in [0.0, 0.1, 20.0, 20.1, 180.0] {
            let event = CompassHeading.event(magneticHeading: 128.5, accuracy: accuracy)
            precondition(event["status"] as? String == (accuracy <= 20 ? "ready" : "calibrating"))
            precondition(event["magneticHeadingDegrees"] as? Double == 128.5)
            precondition(event["accuracyDegrees"] as? Double == accuracy)
            precondition(event["sensorAccuracy"] is NSNull)
            precondition(event["unavailableReason"] is NSNull)
        }

        for heading in [0.0, 359.999] {
            let event = CompassHeading.event(magneticHeading: heading, accuracy: 0)
            precondition(event["status"] as? String == "ready")
            precondition(event["magneticHeadingDegrees"] as? Double == heading)
            precondition(event["accuracyDegrees"] as? Double == 0)
        }

        for heading in [-0.1, 360.0, 361.0, Double.nan, Double.infinity, -Double.infinity] {
            assertUnreliable(CompassHeading.event(magneticHeading: heading, accuracy: 0))
        }
        for accuracy in [-1.0, -0.1, Double.nan, Double.infinity, -Double.infinity] {
            assertUnreliable(CompassHeading.event(magneticHeading: 128.5, accuracy: accuracy))
        }

        for reason in ["sensorNotFound", "sensorFailure"] {
            let event = CompassHeading.unavailable(reason: reason)
            precondition(event["status"] as? String == "unavailable")
            precondition(event["magneticHeadingDegrees"] is NSNull)
            precondition(event["accuracyDegrees"] is NSNull)
            precondition(event["sensorAccuracy"] is NSNull)
            precondition(event["unavailableReason"] as? String == reason)
        }
        print("CompassHeadingTests: 25 cases passed")
    }

    private static func assertUnreliable(_ event: [String: Any]) {
        precondition(event["status"] as? String == "calibrating")
        precondition(event["magneticHeadingDegrees"] is NSNull)
        precondition(event["accuracyDegrees"] is NSNull)
        precondition(event["sensorAccuracy"] is NSNull)
        precondition(event["unavailableReason"] is NSNull)
    }
}
