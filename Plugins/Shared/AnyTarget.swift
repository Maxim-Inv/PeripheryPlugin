import Foundation
import PackagePlugin

struct AnyTarget {
    let name: String
    let type: String?
    let directory: Path
    let files: [Path]
    let dependencyNames: [String]
}

extension AnyTarget {
    init?(target: Target) {
        guard let target = target.sourceModule else { return nil }

        name = target.name
        type = target.type
        directory = target.directory
        files = target.sourceFiles.map(\.path)
        dependencyNames = target.dependencies.map(\.name)
    }
}

private extension SourceModuleTarget {
    var type: String? {
        switch kind {
        case .generic: "library"
        case .executable: "executable"
        case .test: "test"
        default: nil
        }
    }
}

private extension TargetDependency {
    var name: String {
        switch self {
        case let .product(product): product.name
        case let .target(target): target.name
        @unknown default: fatalError("Unhandled TargetDependency")
        }
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension AnyTarget {
    init(context: XcodePluginContext, target: XcodeTarget) {
        name = target.displayName
        type = nil
        directory = context.directory
        files = target.inputFiles.map(\.path)
        dependencyNames = target.dependencies.map(\.name)
    }
}

private extension XcodeTargetDependency {
    var name: String {
        switch self {
        case let .target(target): target.displayName
        case let .product(product): product.name
        @unknown default: fatalError("Unhandled XcodeTargetDependency")
        }
    }
}
#endif
