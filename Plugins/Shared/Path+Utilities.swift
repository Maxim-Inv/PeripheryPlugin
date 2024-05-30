import Foundation
import PackagePlugin

extension Path {
    var isExist: Bool {
        FileManager.default.fileExists(atPath: string)
    }
}

extension [Path] {
    var sourceFiles: Self {
        filter { $0.extension == "swift" }
    }
}
