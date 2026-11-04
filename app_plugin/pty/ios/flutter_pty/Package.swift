// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "flutter_pty",
    platforms: [.iOS("9.0")],
    products: [
        .library(name: "flutter-pty", type: .dynamic, targets: ["flutter_pty"])
    ],
    targets: [
        .target(
            name: "flutter_pty",
            cSettings: [.define("DART_SHARED_LIB")]
        )
    ]
)
