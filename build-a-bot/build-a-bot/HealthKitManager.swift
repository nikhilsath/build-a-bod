import HealthKit
import SwiftData

class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()

    private init() {}

    /// Request permission to read step count and distance data from HealthKit.
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard
            let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount),
            let distance = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
            let stride = HKObjectType.quantityType(forIdentifier: .walkingStepLength)
        else {
            completion(false, NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Required types unavailable"]))
            return
        }

        let typesToRead: Set<HKObjectType> = [stepCount, distance, stride]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            completion(success, error)
        }
    }

    /// Fetch the number of steps taken today and update the local cache.
    func fetchTodayStepCount(context: ModelContext, completion: @escaping (HealthMetric?, Error?) -> Void) {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion(nil, NSError(domain: "HealthKit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Step count type unavailable"]))
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            var metric: HealthMetric?
            if let quantity = result?.sumQuantity() {
                let steps = quantity.doubleValue(for: HKUnit.count())
                if steps > 0 {
                    metric = self.upsertMetric(steps: steps, context: context)
                }
            }

            DispatchQueue.main.async {
                completion(metric, error)
            }
        }

        healthStore.execute(query)
    }

    /// Fetch the walking/running distance for today.
    func fetchTodayDistance(context: ModelContext, completion: @escaping (HealthMetric?, Error?) -> Void) {
        guard let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion(nil, NSError(domain: "HealthKit", code: 3, userInfo: [NSLocalizedDescriptionKey: "Distance type unavailable"]))
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            var metric: HealthMetric?
            if let quantity = result?.sumQuantity() {
                let distance = quantity.doubleValue(for: HKUnit.meter())
                if distance > 0 {
                    metric = self.upsertMetric(distance: distance, context: context)
                }
            }

            DispatchQueue.main.async {
                completion(metric, error)
            }
        }

        healthStore.execute(query)
    }

    /// Fetch the average stride length for today.
    func fetchAverageStrideLength(completion: @escaping (Double?, Error?) -> Void) {
        guard let type = HKObjectType.quantityType(forIdentifier: .walkingStepLength) else {
            completion(nil, NSError(domain: "HealthKit", code: 4, userInfo: [NSLocalizedDescriptionKey: "Stride length type unavailable"]))
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, error in
            var length: Double?
            if let quantity = result?.averageQuantity() {
                length = quantity.doubleValue(for: HKUnit.meter())
            }

            DispatchQueue.main.async {
                completion(length, error)
            }
        }

        healthStore.execute(query)
    }

    /// Update or create today's metric with the provided step count.
    func upsertMetric(steps: Double, context: ModelContext) -> HealthMetric {
        let localStore = LocalHealthStore()
        let startOfDay = Calendar.current.startOfDay(for: Date())
        if let existing = localStore.fetchMetric(for: startOfDay, context: context) {
            existing.steps = Int(steps)
            localStore.updateMetric(existing, context: context)
            return existing
        } else {
            let metric = HealthMetric(date: startOfDay, steps: Int(steps))
            localStore.save(metric: metric, context: context)
            return metric
        }
    }

    /// Update or create today's metric with the provided distance.
    func upsertMetric(distance: Double, context: ModelContext) -> HealthMetric {
        let localStore = LocalHealthStore()
        let startOfDay = Calendar.current.startOfDay(for: Date())
        if let existing = localStore.fetchMetric(for: startOfDay, context: context) {
            existing.distance = distance
            localStore.updateMetric(existing, context: context)
            return existing
        } else {
            let metric = HealthMetric(date: startOfDay, distance: distance)
            localStore.save(metric: metric, context: context)
            return metric
        }
    }
}

