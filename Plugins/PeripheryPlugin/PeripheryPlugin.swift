import Foundation
import PackagePlugin

@main
struct PeripheryPlugin: BuildToolPlugin {
    func createCommand(context: AnyContext, target: AnyTarget) throws -> Command? {
        let sources = target.files
            .sourceFiles

        guard !sources.isEmpty else { return nil }

        let tool = try context.tool(named: "PeripheryRenderer").path
        let path = context.pluginWorkDirectory.appending("PeripheryRenderer.swift")

        return .buildCommand(
            displayName: "PeripheryPlugin",
            executable: tool,
            arguments: [path],
            inputFiles: sources,
            outputFiles: [path]
        )
    }

    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        if let target = AnyTarget(target: target), let command = try createCommand(context: context, target: target) {
            return [command]
        }
        return []
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension PeripheryPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        if let command = try createCommand(context: context, target: AnyTarget(context: context, target: target)) {
            return [command]
        }
        return []
    }
}
#endif
