import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            Text("ExampleApp")
                .onAppear {
                    _ = UnusedProperty(title: "title")
                }
        }
    }
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
