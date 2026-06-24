// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "app_system_metrics_ios",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "app-system-metrics-ios", targets: ["app_system_metrics_ios"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "app_system_metrics_ios",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
