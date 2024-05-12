import Foundation

@main
struct PeripheryRenderer {
    static func main() throws {
        let path = ProcessInfo.processInfo.arguments[1]

        do {
            let output = try String(contentsOfFile: path)
            print(output.replacingOccurrences(of: "// ", with: ""))
        } catch {
            try Data().write(to: URL(fileURLWithPath: path))
        }
    }
}
