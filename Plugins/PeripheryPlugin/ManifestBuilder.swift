import Foundation
import PackagePlugin

struct ManifestBuilder {
    let package: PackagePlugin.Package
    let targets: [PackagePlugin.Target]

    func build(path: String) throws {
        let spmPackage = Package(
            name: package.displayName,
            path: package.directory.string,
            targets: targets.compactMap { target in
                guard let target = target.sourceModule, let type = target.type else { return nil }

                let sources = target
                    .sourceFiles(withSuffix: "swift")
                    .map { $0.path.string.replacingOccurrences(of: target.directory.string + "/", with: "") }

                return Target(
                    name: target.name,
                    sources: sources,
                    path: target.directory.string.replacingOccurrences(of: package.directory.string + "/", with: ""),
                    moduleType: "SwiftTarget",
                    type: type,
                    targetDependencies: Set(target.dependencies.map(\.name))
                )
            }
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        try encoder.encode(spmPackage).write(to: URL(filePath: path))
    }
}

private extension ManifestBuilder {
    // Align to https://github.com/peripheryapp/periphery/blob/master/Sources/PeripheryKit/SPM/SPM.swift
    struct Package: Encodable {
        let name: String
        let path: String
        let targets: [Target]
    }

    struct Target: Encodable {
        let name: String
        let sources: [String]
        let path: String
        let moduleType: String
        let type: String
        let targetDependencies: Set<String>?
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
