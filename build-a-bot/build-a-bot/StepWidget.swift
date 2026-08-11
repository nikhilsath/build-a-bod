import SwiftUI
import SwiftData

struct StepWidget: View {
    @State private var stepCount: Double = 0
    @State private var distance: Double = 0
    @State private var showingSteps = true
    @Environment(\.modelContext) private var modelContext
    private let localStore = LocalHealthStore()

    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            if showingSteps {
                Text("\(Int(stepCount))")
                    .font(.largeTitle)
                    .bold()
                Text("steps")
                    .font(.caption)
                    .baselineOffset(-4)
            } else {
                Text(formatDistance(distance))
                    .font(.largeTitle)
                    .bold()
                Text(distanceUnitLabel())
                    .font(.caption)
                    .baselineOffset(-4)
            }
        }
        .onTapGesture {
            showingSteps.toggle()
            if !showingSteps {
                fetchDistanceIfNeeded()
            }
        }
        .onAppear {
            localStore.loadDefaultMetricsIfNeeded(context: modelContext)

            let today = Date()
            if let metric = localStore.fetchMetric(for: today, context: modelContext) {
                stepCount = Double(metric.steps)
                distance = metric.distance
            }

            HealthKitManager.shared.fetchTodayStepCount(context: modelContext) { metric, _ in
                if let metric = metric {
                    stepCount = Double(metric.steps)
                    distance = metric.distance
                }
            }
        }
    }

    private func fetchDistanceIfNeeded() {
        guard distance == 0 else { return }

        HealthKitManager.shared.fetchTodayDistance(context: modelContext) { metric, _ in
            if let metric = metric, metric.distance > 0 {
                distance = metric.distance
            } else {
                HealthKitManager.shared.fetchAverageStrideLength { stride, _ in
                    guard let stride = stride, stepCount > 0 else { return }
                    let computed = stepCount * stride
                    distance = computed
                    HealthKitManager.shared.upsertMetric(distance: computed, context: modelContext)
                }
            }
        }
    }

    private func formatDistance(_ meters: Double) -> String {
        let usesMetric = Locale.current.usesMetricSystem
        let value = usesMetric ? meters / 1000 : meters / 1609.34
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    private func distanceUnitLabel() -> String {
        Locale.current.usesMetricSystem ? "km" : "mi"
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: HealthMetric.self, configurations: config)
        let store = LocalHealthStore()
        store.loadDefaultMetricsIfNeeded(context: container.mainContext)
        return StepWidget()
            .modelContainer(container)
    } catch {
        return StepWidget()
    }
}
