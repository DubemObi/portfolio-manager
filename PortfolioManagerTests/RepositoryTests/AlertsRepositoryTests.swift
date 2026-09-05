//
//  AlertsRepositoryTests.swift
//  PortfolioManagerTests
//

import XCTest
import SwiftData
@testable import PortfolioManager

final class AlertsRepositoryTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    var repository: AlertsRepository!

    override func setUpWithError() throws {
        let schema = Schema([RebalanceDecision.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [configuration])
        context = ModelContext(container)
        repository = AlertsRepository(context: context)
    }

    func test_recordDecision_persistsWithCorrectFields() throws {
        let snoozeDate = Date.now.addingTimeInterval(60 * 60 * 24 * 7)
        try repository.recordDecision(assetClass: .equities, drift: 0.08, healthScore: 72,
                                       decision: .snoozed, snoozeUntil: snoozeDate)

        let decisions = try context.fetch(FetchDescriptor<RebalanceDecision>())
        XCTAssertEqual(decisions.count, 1)
        XCTAssertEqual(decisions.first?.assetClass, .equities)
        XCTAssertEqual(decisions.first?.decision, .snoozed)
        XCTAssertNotNil(decisions.first?.snoozeUntil)
    }
}
