import ProjectDescription

let project = Project(
    name: "ExampleApp",
    packages: [
        // .package(path: "..")
        .package(url: "https://github.com/rock88/PeripheryPlugin", from: "1.0.0")
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
                .package(product: "PeripheryPlugin", type: .plugin)
            ]
        )
    ]
)
