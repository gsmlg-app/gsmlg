// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "app_system_metrics_macos",
    platforms: [
        .macOS("10.14")
    ],
    products: [
        .library(name: "app-system-metrics-macos", targets: ["app_system_metrics_macos"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "app_system_metrics_macos",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
