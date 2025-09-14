import SwiftUI
import SwiftData

struct StepCountView: View {
    @State private var stepCount: Double = 0
    @Environment(\.modelContext) private var modelContext
    private let localStore = LocalHealthStore()

    var body: some View {
        VStack(spacing: 20) {
            Text("Today's Steps")
                .font(.title)
            Text("\(Int(stepCount))")
                .font(.largeTitle)
                .bold()
        }
        .onAppear {
            let today = Date()
            if let metric = localStore.fetchMetric(for: today, context: modelContext) {
                stepCount = Double(metric.steps)
            } else {
                HealthKitManager.shared.fetchTodayStepCount { count, _ in
                    stepCount = count
                    let metric = HealthMetric(
                        date: Calendar.current.startOfDay(for: today),
                        steps: Int(count),
                        distance: 0
                    )
                    localStore.save(metric: metric, context: modelContext)
                }
            }
        }
        .padding()
    }
}

#Preview {
    StepCountView()
}
