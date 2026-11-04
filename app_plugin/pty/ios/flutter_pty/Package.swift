// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "flutter_pty",
    platforms: [.iOS("14.0")],
    products: [
        .library(name: "flutter-pty", type: .dynamic, targets: ["flutter_pty"])
    ],
    targets: [
        .target(
            name: "flutter_pty",
            exclude: ["CMakeLists.txt", "flutter_pty_win.c", "flutter_pty_unix.c", "forkpty.c", "include/dart_api_dl.c"],
            sources: ["flutter_pty.c"],
            publicHeadersPath: "include"
        )
    ]
)
