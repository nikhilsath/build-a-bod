import SwiftUI
import SwiftData
import FirebaseCore

@main
struct build_a_botApp: App {
    init() {
        FirebaseApp.configure()
        HealthKitManager.shared.requestAuthorization { success, error in
            if success {
                print("HealthKit authorization granted")
            } else {
                print("HealthKit authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Provide SwiftData context to the whole view tree
        .modelContainer(for: [Item.self, HealthMetric.self])
    }
}
