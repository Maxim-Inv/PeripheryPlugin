import Foundation
import PackagePlugin

@main
struct PeripheryPlugin: CommandPlugin {
    func perform(context: AnyPluginContext, arguments: [String], isPackage: Bool) throws {
        var extractor = ArgumentExtractor(arguments)

        let names = extractor.extractOption(named: "target")
        let targets = try context.targets(named: names)

        guard !targets.isEmpty else { return }

        let manifestPath = context.pluginWorkDirectory.appending("PeripheryPlugin_Manifest.json")

        if isPackage {
            let manifest = try context.exec(tool: "swift") { arguments in
                arguments.append("package")
                arguments.append("describe")
                arguments.append("--type")
                arguments.append("json")
            }

            guard !manifest.result.isEmpty else {
                Diagnostics.error("Failed to perform `swift package describe`, try to restart Xcode")
                return
            }

            try manifest.result.write(toFile: manifestPath.string, atomically: true, encoding: .utf8)
        }

        let dataStore = context.pluginWorkDirectory
            .removingLastComponent()
            .removingLastComponent()
            .removingLastComponent()
            .appending("Index.noindex", "DataStore")

        let output = try context.exec(tool: "periphery") { arguments in
            arguments.append("scan")

            if isPackage {
                arguments.append("--json-package-manifest-path")
                arguments.append(manifestPath)
            } else {
                arguments.append("--project")
                arguments.append(context.directory.appending(context.displayName + ".xcodeproj"))
                arguments.append("--schemes")
                arguments.append(contentsOf: names)
                arguments.append("--skip-schemes-validation")
            }

            arguments.append("--targets")
            arguments.append(contentsOf: names)
            arguments.append("--skip-build")
            arguments.append("--index-store-path")
            arguments.append(dataStore)
            arguments.append("--format")
            arguments.append("xcode")

            // Configuration
            arguments.append("--retain-public")
            arguments.append("--disable-redundant-public-analysis")
        }

        for target in targets {
            let path = context.pluginWorkDirectory.removingLastComponent().appending(
                context.id + ".output",
                target.name,
                "PeripheryRendererPlugin"
            )

            try FileManager.default.createDirectory(atPath: path.string, withIntermediateDirectories: true)

            let string = output
                .result
                .components(separatedBy: "\n")
                .filter { $0.hasPrefix(target.directory.string) }
                .map { "// \($0)" }
                .joined(separator: "\n")

            try string.data(using: .utf8)?.write(to: URL(fileURLWithPath: path.appending("PeripheryRenderer.swift").string))
        }

        if output.error.contains("error:") {
            Diagnostics.error(output.error)
        } else {
            Diagnostics.remark(output.result)
        }
    }

    func performCommand(context: PluginContext, arguments: [String]) async throws {
        try perform(context: context, arguments: arguments, isPackage: true)
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension PeripheryPlugin: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        try perform(context: context, arguments: arguments, isPackage: false)
    }
}
#endif
