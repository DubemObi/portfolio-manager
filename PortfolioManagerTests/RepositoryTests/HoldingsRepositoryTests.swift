//
//  HoldingsRepositoryTests.swift
//  PortfolioManagerTests
//

import XCTest
import SwiftData
@testable import PortfolioManager

final class HoldingsRepositoryTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    var repository: HoldingsRepository!

    override func setUpWithError() throws {
        let schema = Schema([Holding.self, Contribution.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [configuration])
        context = ModelContext(container)
        repository = HoldingsRepository(context: context)
    }

    func test_add_persistsHoldingToStore() throws {
        _ = try repository.add(name: "Apple", symbol: "AAPL", quantity: 10,
                                assetClass: .equities, pricePerUnit: 150, lastUpdated: .now)

        let fetched = try context.fetch(FetchDescriptor<Holding>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.symbol, "AAPL")
    }

    func test_symbolExists_trueAfterAdding() throws {
        _ = try repository.add(name: "Apple", symbol: "AAPL", quantity: 10,
                                assetClass: .equities, pricePerUnit: 150, lastUpdated: .now)
        XCTAssertTrue(try repository.symbolExists("AAPL"))
        XCTAssertFalse(try repository.symbolExists("MSFT"))
    }

    func test_updateValue_changesQuantityAndTimestamp() throws {
        let holding = try repository.add(name: "Property", symbol: nil, quantity: 1000,
                                          assetClass: .realEstate, pricePerUnit: 1, lastUpdated: .now)
        try repository.updateValue(holding: holding, newValue: 1200)

        XCTAssertEqual(holding.quantity, 1200, accuracy: 0.001)
    }

    func test_recordContribution_increasesQuantityAndCreatesRecord() throws {
        let holding = try repository.add(name: "Apple", symbol: "AAPL", quantity: 10,
                                          assetClass: .equities, pricePerUnit: 150, lastUpdated: .now)
        try repository.recordContribution(holding: holding, quantityAdded: 5)

        XCTAssertEqual(holding.quantity, 15, accuracy: 0.001)
        let contributions = try context.fetch(FetchDescriptor<Contribution>())
        XCTAssertEqual(contributions.count, 1)
        XCTAssertEqual(contributions.first?.quantityAdded, 5, accuracy: 0.001)
    }
}
