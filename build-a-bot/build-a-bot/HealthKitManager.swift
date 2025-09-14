import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()

    private init() {}
}

