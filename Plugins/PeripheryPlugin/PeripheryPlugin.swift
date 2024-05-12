import Foundation
import PackagePlugin

@main
struct PeripheryPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        var extractor = ArgumentExtractor(arguments)

        let names = extractor.extractOption(named: "target")
        let targets = try context.package.targets(named: names)

        guard !targets.isEmpty else { return }

        let manifestPath = context.pluginWorkDirectory.appending("PeripheryPlugin_Manifest.json")
        let manifestBuilder = ManifestBuilder(package: context.package, targets: targets)
        try manifestBuilder.build(path: manifestPath.string)

        let dataStore = context.pluginWorkDirectory
            .removingLastComponent()
            .removingLastComponent()
            .removingLastComponent()
            .appending("Index.noindex", "DataStore")

        let output = try context.exec(tool: "periphery") { arguments in
            arguments.append("scan")
            arguments.append("--targets")
            arguments.append(contentsOf: names)
            arguments.append("--skip-build")
            arguments.append("--index-store-path")
            arguments.append(dataStore)
            arguments.append("--format")
            arguments.append("xcode")
            arguments.append("--retain-public")
            arguments.append("--disable-redundant-public-analysis")
            arguments.append("--json-package-manifest-path")
            arguments.append(manifestPath)
        }

        for target in targets {
            let path = context.pluginWorkDirectory.removingLastComponent().appending(
                context.package.id + ".output",
                target.name,
                "PeripheryRendererPlugin"
            )

            try FileManager.default.createDirectory(atPath: path.string, withIntermediateDirectories: true)

            let string = output
                .components(separatedBy: "\n")
                .filter { $0.hasPrefix(target.directory.string) }
                .map { "// \($0)" }
                .joined(separator: "\n")

            try string.data(using: .utf8)?.write(to: URL(fileURLWithPath: path.appending("PeripheryRenderer.swift").string))
        }

        if output.contains("error:") {
            Diagnostics.error(output)
        } else {
            Diagnostics.remark(output)
        }
    }
}

private extension PluginContext {
    @discardableResult
    func exec(tool: String, argumentsHandler: (inout [CustomStringConvertible]) -> Void) throws -> String {
        let tool = try self.tool(named: tool)

        var arguments: [CustomStringConvertible] = []
        argumentsHandler(&arguments)

        let pipe = Pipe()
        let process = Process()
        process.launchPath = tool.path.string
        process.arguments = arguments.map(\.description)
        process.standardOutput = pipe
        process.standardError = pipe
        try process.run()
        process.waitUntilExit()

        let data = try? pipe.fileHandleForReading.readToEnd()
        return data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
    }
}
