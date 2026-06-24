// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "camera_macos",
    platforms: [
        .macOS("10.15")
    ],
    products: [
        .library(name: "camera-macos", targets: ["camera_macos"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "camera_macos",
            dependencies: []
        )
    ]
)
