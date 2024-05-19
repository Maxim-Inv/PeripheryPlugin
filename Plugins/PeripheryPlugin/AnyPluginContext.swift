import Foundation
import PackagePlugin

protocol AnyPluginContext {
    var id: String { get }
    var displayName: String { get }
    var directory: Path { get }
    var pluginWorkDirectory: Path { get }

    func targets(named targetNames: [String]) throws -> [AnyTarget]
    func tool(named name: String) throws -> PluginContext.Tool
}

struct AnyTarget {
    let name: String
    let directory: Path
}

extension AnyPluginContext {
    @discardableResult
    func exec(tool: String, argumentsHandler: (inout [CustomStringConvertible]) -> Void) throws -> (result: String, error: String) {
        let tool = try self.tool(named: tool)

        var arguments: [CustomStringConvertible] = []
        argumentsHandler(&arguments)

        let (pipe, error) = (Pipe(), Pipe())
        let process = Process()
        process.launchPath = tool.path.string
        process.arguments = arguments.map(\.description)
        process.standardOutput = pipe
        process.standardError = error
        try process.run()
        process.waitUntilExit()
        return (pipe.readString(), error.readString())
    }
}

private extension Pipe {
    func readString() -> String {
        let data = try? fileHandleForReading.readToEnd()
        return data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
    }
}

extension PluginContext: AnyPluginContext {
    var id: String { package.id }
    var displayName: String { package.displayName }
    var directory: Path { package.directory }

    func targets(named targetNames: [String]) throws -> [AnyTarget] {
        try package.targets(named: targetNames).map { AnyTarget(name: $0.name, directory: $0.directory) }
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension XcodePluginContext: AnyPluginContext {
    var id: String { xcodeProject.displayName }
    var displayName: String { xcodeProject.displayName }
    var directory: Path { xcodeProject.directory }

    func targets(named targetNames: [String]) throws -> [AnyTarget] {
        xcodeProject.targets
            .filter { targetNames.contains($0.displayName) }
            .map { AnyTarget(name: $0.displayName, directory: xcodeProject.directory) }
    }
}

#endif
