// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PeripheryPlugin",
    products: [
        .plugin(name: "PeripheryPlugin", targets: ["PeripheryPlugin"]),
        .plugin(name: "PeripheryRendererPlugin", targets: ["PeripheryRendererPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/rock88/periphery.git", branch: "plugin_support")
    ],
    targets: [
        // PeripheryPlugin
        .plugin(
            name: "PeripheryPlugin",
            capability: .command(
                intent: .custom(verb: "periphery", description: "A tool to identify unused code in Swift projects"),
                permissions: []
            ),
            dependencies: [
                "periphery"
            ]
        ),
        // PeripheryRenderer
        .executableTarget(name: "PeripheryRenderer"),
        .plugin(
            name: "PeripheryRendererPlugin",
            capability: .buildTool,
            dependencies: [
                "PeripheryRenderer"
            ]
        )
    ]
)
