import Foundation
import PackagePlugin

@main
struct PeripheryClean: CommandPlugin {
    func perform(context: AnyContext, arguments: [String]) throws {
        var extractor = ArgumentExtractor(arguments)

        let targets = context.targets(named: extractor.extractOption(named: "target"))

        for target in targets {
            let path = context.pluginWorkDirectory.removingLastComponent().appending(
                context.id + ".output",
                target.name,
                "PeripheryPlugin"
            )
            .appending("PeripheryRenderer.swift")

            if FileManager.default.fileExists(atPath: path.string) {
                try Data().write(to: URL(fileURLWithPath: path.string))
            }
        }
    }

    func performCommand(context: PluginContext, arguments: [String]) async throws {
        try perform(context: context, arguments: arguments)
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension PeripheryClean: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        try perform(context: context, arguments: arguments)
    }
}
#endif
