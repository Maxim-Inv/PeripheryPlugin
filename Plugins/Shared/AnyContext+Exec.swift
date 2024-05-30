import Foundation

final class ArgumentsBuilder {
    private var storage: [CustomStringConvertible] = []

    var arguments: [String] {
        storage.map(\.description)
    }

    func append(flag: CustomStringConvertible, argument: CustomStringConvertible) {
        storage.append(contentsOf: [flag, argument])
    }

    func append<T: Sequence>(flag: CustomStringConvertible, arguments: T) where T.Element: CustomStringConvertible {
        storage.append(flag)
        arguments.forEach { storage.append($0) }
    }

    func append(argument: CustomStringConvertible) {
        storage.append(argument)
    }

    func append<T: Sequence>(arguments: T) where T.Element: CustomStringConvertible {
        arguments.forEach { storage.append($0) }
    }
}

extension AnyContext {
    @discardableResult
    func exec(tool: String, arguments: (ArgumentsBuilder) -> Void) throws -> (result: String, error: String) {
        let tool = try self.tool(named: tool)
        return try Exec(tool: tool.path.string, arguments: arguments)
    }
}

@discardableResult
func Exec(tool: String, arguments: (ArgumentsBuilder) -> Void) throws -> (result: String, error: String) {
    let builder = ArgumentsBuilder()
    arguments(builder)

    let (pipe, error) = (Pipe(), Pipe())
    let process = Process()
    process.launchPath = tool
    process.arguments = builder.arguments
    process.standardOutput = pipe
    process.standardError = error
    try process.run()
    process.waitUntilExit()
    return (pipe.readString(), error.readString())
}

private extension Pipe {
    func readString() -> String {
        String(data: fileHandleForReading.availableData, encoding: .utf8) ?? ""
    }
}
