//
//  build_a_botTests.swift
//  build-a-botTests
//
//  Created by Nikhil Sathyanarayana on 07/09/2025.
//

import Testing
@testable import build_a_bot
import SwiftData

struct build_a_botTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    @MainActor
    @Test func nonZeroFetchOverwritesCachedMetric() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: HealthMetric.self, configurations: config)
        let context = container.mainContext
        let store = LocalHealthStore()

        let today = Date()
        let startOfDay = Calendar.current.startOfDay(for: today)
        let initial = HealthMetric(date: startOfDay, steps: 100)
        store.save(metric: initial, context: context)

        _ = HealthKitManager.shared.upsertMetric(steps: 200, context: context)

        let updated = store.fetchMetric(for: today, context: context)
        #expect(updated?.steps == 200)
    }

}
