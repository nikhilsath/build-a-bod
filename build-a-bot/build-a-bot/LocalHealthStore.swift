import Foundation
import SwiftData

final class LocalHealthStore {
    func fetchMetric(for date: Date, context: ModelContext) -> HealthMetric? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let predicate = #Predicate<HealthMetric> { metric in
            metric.date == startOfDay
        }
        let descriptor = FetchDescriptor<HealthMetric>(predicate: predicate)
        return try? context.fetch(descriptor).first
    }

    func save(metric: HealthMetric, context: ModelContext) {
        context.insert(metric)
        try? context.save()
    }

    func updateMetric(_ metric: HealthMetric, context: ModelContext) {
        // Assume metric is already managed by the context; simply save changes
        try? context.save()
    }

    /// Populate the store with bundled defaults when appropriate.
    /// - Parameters:
    ///   - context: The model context to insert metrics into.
    ///
    /// Loads data when the store is empty or when running in DEBUG / preview
    /// modes so the UI can function without HealthKit.
    func loadDefaultMetricsIfNeeded(context: ModelContext) {
        let fetch = FetchDescriptor<HealthMetric>()
        let existing = (try? context.fetch(fetch)) ?? []

        #if DEBUG
        let shouldLoad = existing.isEmpty || ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        #else
        let shouldLoad = existing.isEmpty
        #endif

        if shouldLoad {
            loadDefaultMetrics(context: context)
        }
    }

    /// Loads metrics from `DefaultHealthMetrics.json` in the app bundle.
    private func loadDefaultMetrics(context: ModelContext) {
        guard let url = Bundle.main.url(forResource: "DefaultHealthMetrics", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return }

        struct DefaultMetric: Decodable { let steps: Int; let distance: Double }

        do {
            let defaults = try JSONDecoder().decode([DefaultMetric].self, from: data)
            for (index, metric) in defaults.enumerated() {
                if let date = Calendar.current.date(byAdding: .day, value: -index, to: Date()) {
                    let start = Calendar.current.startOfDay(for: date)
                    let model = HealthMetric(date: start, steps: metric.steps, distance: metric.distance)
                    context.insert(model)
                }
            }
            try? context.save()
        } catch {
            print("Failed to decode DefaultHealthMetrics.json: \(error)")
        }
    }
}

