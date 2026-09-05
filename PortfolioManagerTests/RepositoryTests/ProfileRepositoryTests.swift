//
//  ProfileRepositoryTests.swift
//  PortfolioManagerTests
//

import XCTest
import SwiftData
@testable import PortfolioManager

final class ProfileRepositoryTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    var repository: ProfileRepository!

    override func setUpWithError() throws {
        let schema = Schema([FinancialProfile.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [configuration])
        context = ModelContext(container)
        repository = ProfileRepository(context: context)
    }

    func test_save_createsNewProfileWhenNoneExists() throws {
        try repository.save(name: "Alex", monthlyIncome: 3000, monthlyExpenses: 1500,
                             monthlyDebtPayments: 0, currentSavings: 5000, riskCategory: .moderate,
                             financialGoal: .longTermWealth, customGoalDescription: nil, targetAmount: nil)

        let profiles = try context.fetch(FetchDescriptor<FinancialProfile>())
        XCTAssertEqual(profiles.count, 1)
        XCTAssertEqual(profiles.first?.name, "Alex")
    }

    func test_save_updatesExistingProfileRatherThanDuplicating() throws {
        try repository.save(name: "Alex", monthlyIncome: 3000, monthlyExpenses: 1500,
                             monthlyDebtPayments: 0, currentSavings: 5000, riskCategory: .moderate,
                             financialGoal: .longTermWealth, customGoalDescription: nil, targetAmount: nil)

        try repository.save(name: "Alex", monthlyIncome: 3500, monthlyExpenses: 1500,
                             monthlyDebtPayments: 0, currentSavings: 5000, riskCategory: .aggressive,
                             financialGoal: .longTermWealth, customGoalDescription: nil, targetAmount: nil)

        let profiles = try context.fetch(FetchDescriptor<FinancialProfile>())
        XCTAssertEqual(profiles.count, 1, "A second save() must update the existing profile, not create a duplicate")
        let profile = try XCTUnwrap(profiles.first)
        XCTAssertEqual(profile.monthlyIncome, 3500, accuracy: 0.001)
        XCTAssertEqual(profiles.first?.riskCategory, .aggressive)
    }
}
