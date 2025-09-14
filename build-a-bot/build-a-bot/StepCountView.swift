import SwiftUI

struct StepCountView: View {
    @State private var stepCount: Double = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("Today's Steps")
                .font(.title)
            Text("\(Int(stepCount))")
                .font(.largeTitle)
                .bold()
        }
        .onAppear {
            HealthKitManager.shared.fetchTodayStepCount { count, _ in
                stepCount = count
            }
        }
        .padding()
    }
}

#Preview {
    StepCountView()
}
