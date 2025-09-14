import SwiftUI
#if canImport(FirebaseCore)
import FirebaseCore
#endif
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Button("Check Firebase configured") {
                    print("Firebase configured:", FirebaseApp.app() != nil)
                }

                #if canImport(FirebaseFirestore)
                Button("Test Firestore write") {
                    Firestore.firestore().collection("debug")
                        .addDocument(data: ["hello":"world","ts":Date()]) { err in
                            print(err == nil ? "Firestore write OK" : "Firestore error: \(err!)")
                        }
                }
                #endif

                NavigationLink("Show Today's Steps") {
                    StepCountView()
                }
            }
            .buttonStyle(.bordered)
            .padding()
            .navigationTitle("Build-A-Bod")
            .onAppear { print("DashboardView appeared") }
        }
    }
}

