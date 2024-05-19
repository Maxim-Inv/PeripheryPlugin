import ProjectDescription

let project = Project(
    name: "ExampleApp",
    packages: [
        .package(path: "..")
    ],
    targets: [
        .target(
            name: "App",
            destinations: .macOS,
            product: .app,
            bundleId: "example.app",
            deploymentTargets: .macOS("13.0"),
            sources: "Sources/**",
            dependencies: [
                .package(product: "PeripheryRendererPlugin", type: .plugin)
            ]
        )
    ]
)
