import Foundation
import PackagePlugin

@main
struct PeripheryRendererPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: PackagePlugin.Target) async throws -> [Command] {
        guard let target = target.sourceModule else { return [] }

        let path = context.pluginWorkDirectory.appending("PeripheryRenderer.swift")
        let tool = try context.tool(named: "PeripheryRenderer")

        return [.buildCommand(
            displayName: "PeripheryRendererPlugin",
            executable: tool.path,
            arguments: [path],
            inputFiles: target.sourceFiles(withSuffix: "swift").map(\.path),
            outputFiles: [path]
        )]
    }
}
