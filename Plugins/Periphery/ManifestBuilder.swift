import Foundation
import PackagePlugin

struct ManifestBuilder {
    let context: AnyContext
    let targets: [AnyTarget]

    func build(path: String) throws {
        let spmPackage = Package(
            name: context.displayName,
            path: context.directory.string,
            targets: targets.compactMap { target in
                guard let type = target.type else { return nil }

                let sources = target
                    .files
                    .sourceFiles
                    .map { $0.string.replacingOccurrences(of: target.directory.string + "/", with: "") }

                return Target(
                    name: target.name,
                    sources: sources,
                    path: target.directory.string.replacingOccurrences(of: context.directory.string + "/", with: ""),
                    moduleType: "SwiftTarget",
                    type: type,
                    targetDependencies: Set(target.dependencyNames)
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
