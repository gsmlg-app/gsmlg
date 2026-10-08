// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "app_compass",
    platforms: [.iOS("17.0")],
    products: [
        .library(name: "app-compass", targets: ["app_compass"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "app_compass",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
