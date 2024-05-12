// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Example",
    products: [
        .library(name: "Example", targets: ["Example"])
    ],
    dependencies: [
        .package(path: "..")
    ],
    targets: [
        .target(
            name: "Example",
            plugins: [
                .plugin(name: "PeripheryRendererPlugin", package: "PeripheryPlugin")
            ]
        )
    ]
)
