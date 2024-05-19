import Foundation

public func test() {
    _ = UnusedProperty(title: "title")
    print("test")
}

func unusedFunction() {
    //
}

protocol UnusedProtocol {
    //
}

struct UnusedStruct {
    let title: String
}

struct UnusedProperty {
    let title: String
}
