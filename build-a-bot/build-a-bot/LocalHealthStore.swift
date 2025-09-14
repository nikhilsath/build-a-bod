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
}

