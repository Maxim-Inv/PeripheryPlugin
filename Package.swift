// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PeripheryPlugin",
    products: [
        .plugin(name: "Periphery", targets: ["Periphery"]),
        .plugin(name: "Periphery (Clean)", targets: ["Periphery (Clean)"]),
        .plugin(name: "PeripheryPlugin", targets: ["PeripheryPlugin"])
    ],
    targets: [
        // Periphery
        // https://github.com/peripheryapp/periphery/releases
        .binaryTarget(
            name: "PeripheryBinary",
            url: "https://github.com/peripheryapp/periphery/releases/download/3.2.0/periphery-3.2.0.artifactbundle.zip",
            checksum: "0b9a8ced53c6aadcfd61849a3823ce689de81682d75bc8627abb53f1478853a4"
        ),
        .plugin(
            name: "Periphery",
            capability: .command(
                intent: .custom(verb: "periphery", description: "A tool to identify unused code in Swift projects"),
                permissions: []
            ),
            dependencies: [
                "PeripheryBinary"
            ]
        ),
        .plugin(
            name: "Periphery (Clean)",
            capability: .command(
                intent: .custom(verb: "periphery_clean", description: "Clean Periphery cache"),
                permissions: []
            ),
            path: "Plugins/PeripheryClean"
        ),
        // PeripheryPlugin
        .executableTarget(name: "PeripheryRenderer"),
        .plugin(
            name: "PeripheryPlugin",
            capability: .buildTool,
            dependencies: [
                "PeripheryRenderer"
            ]
        )
    ]
)
