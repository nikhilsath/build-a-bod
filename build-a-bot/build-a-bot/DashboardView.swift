import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            VStack {
                StepWidget()
            }
            .padding()
            .navigationTitle("Build-A-Bod")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Build-A-Bod")
                }
            }
            .onAppear { print("DashboardView appeared") }
        }
    }
}

