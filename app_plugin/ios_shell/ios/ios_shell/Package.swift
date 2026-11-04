// swift-tools-version: 5.9

import PackageDescription

let frameworks = [
    "ios_system", "shell", "files", "text", "tar", "awk", "openssl",
    "libssh2", "curl_ios", "network_ios", "lua_ios", "lg2", "Python",
]

let package = Package(
    name: "ios_shell",
    platforms: [.iOS("14.0")],
    products: [
        .library(name: "ios-shell", targets: ["ios_shell"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "ios_shell",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                "ios_shell_native",
            ] + frameworks.map { .target(name: $0) }
        ),
        .target(
            name: "ios_shell_native",
            dependencies: frameworks.map { .target(name: $0) },
            exclude: ["IosShellPlugin.swift", "commandDictionary.plist", "ios_shell-Bridging-Header.h"],
            publicHeadersPath: "."
        ),
    ] + frameworks.map {
        .binaryTarget(name: $0, path: "Frameworks/\($0).xcframework")
    }
)
