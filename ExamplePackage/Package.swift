// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Example",
    products: [
        .library(name: "Example", targets: ["Example"])
    ],
    dependencies: [
        // .package(path: "..")
        .package(url: "https://github.com/rock88/PeripheryPlugin", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Example",
            plugins: [
                .plugin(name: "PeripheryPlugin", package: "PeripheryPlugin")
            ]
        )
    ]
)
