import Foundation
import SwiftData

@Model
final class HealthMetric {
    var date: Date
    var steps: Int
    var distance: Double

    init(date: Date, steps: Int = 0, distance: Double = 0) {
        self.date = date
        self.steps = steps
        self.distance = distance
    }
}

