import Foundation
import PackagePlugin

@main
struct Periphery: CommandPlugin {
    func perform(context: AnyContext, arguments: [String], isPackage: Bool) throws {
        var extractor = ArgumentExtractor(arguments)

        let targets = context.targets(named: extractor.extractOption(named: "target"))
        let names = targets.map(\.name)

        guard !targets.isEmpty else { return }

        let manifestPath = context.pluginWorkDirectory.appending("PeripheryPlugin_Manifest.json")
        let configPath = context.pluginWorkDirectory.appending(".periphery.yml")

        if isPackage {
            let manifest = try context.exec(tool: "swift") { builder in
                builder.append(argument: "package")
                builder.append(argument: "describe")
                builder.append(flag: "--type", argument: "json")
            }

            if manifest.result.isEmpty {
                Diagnostics.warning("Failed to perform `swift package describe`, try to restart Xcode")
                Diagnostics.remark("Fallback to ManifestBuilder...")

                let builder = ManifestBuilder(context: context, targets: targets)
                try builder.build(path: manifestPath.string)
            } else {
                try manifest.result.write(toFile: manifestPath.string, atomically: true, encoding: .utf8)
            }
        }

        let dataStore = context.pluginWorkDirectory
            .removingLastComponent()
            .removingLastComponent()
            .removingLastComponent()
            .appending("Index.noindex", "DataStore")

        let output = try context.exec(tool: "periphery") { builder in
            builder.append(argument: "scan")

            if isPackage {
                builder.append(flag: "--json-package-manifest-path", argument: manifestPath)
            } else {
                builder.append(flag: "--project", argument: context.directory.appending(context.displayName + ".xcodeproj"))
                builder.append(flag: "--schemes", arguments: names)
                builder.append(argument: "--skip-schemes-validation")
            }

            builder.append(flag: "--targets", arguments: names)
            builder.append(argument: "--skip-build")
            builder.append(flag: "--index-store-path", argument: dataStore)
            builder.append(flag: "--format", argument: "xcode")

            if configPath.isExist {
                builder.append(flag: "--config", argument: configPath)
            }
        }

        for target in targets {
            let path = context.pluginWorkDirectory.removingLastComponent().appending(
                context.id + ".output",
                target.name,
                "PeripheryPlugin"
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
            exit(1)
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

extension Periphery: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        try perform(context: context, arguments: arguments, isPackage: false)
    }
}
#endif
