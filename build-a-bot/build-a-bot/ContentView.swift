import SwiftUI
#if canImport(FirebaseCore)
import FirebaseCore
#endif
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Build-A-Bod").font(.largeTitle).bold()

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
        }
        .padding()
        .onAppear { print("ContentView appeared") }
    }
}
