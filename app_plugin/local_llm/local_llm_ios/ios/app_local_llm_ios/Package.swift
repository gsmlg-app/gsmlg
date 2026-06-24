// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "app_local_llm_ios",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .library(name: "app-local-llm-ios", targets: ["app_local_llm_ios"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "app_local_llm_ios",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
