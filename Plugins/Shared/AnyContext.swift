import Foundation
import PackagePlugin

protocol AnyContext {
    var id: String { get }
    var displayName: String { get }
    var directory: Path { get }
    var pluginWorkDirectory: Path { get }
    var targets: [AnyTarget] { get }

    func tool(named name: String) throws -> PluginContext.Tool
}

extension AnyContext {
    func targets<T: Collection>(named: T) -> [AnyTarget] where T.Element == String {
        targets.filter { named.contains($0.name) }
    }
}

extension PluginContext: AnyContext {
    var id: String { package.id }
    var displayName: String { package.displayName }
    var directory: Path { package.directory }
    var targets: [AnyTarget] { package.targets.compactMap(AnyTarget.init) }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension XcodePluginContext: AnyContext {
    var id: String { xcodeProject.displayName }
    var displayName: String { xcodeProject.displayName }
    var directory: Path { xcodeProject.directory }
    var targets: [AnyTarget] { xcodeProject.targets.map { AnyTarget(context: self, target: $0) } }
}
#endif
