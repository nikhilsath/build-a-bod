import SwiftUI
import SwiftData
import FirebaseCore

@main
struct build_a_botApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Provide SwiftData context to the whole view tree
        .modelContainer(for: [Item.self])
    }
}
