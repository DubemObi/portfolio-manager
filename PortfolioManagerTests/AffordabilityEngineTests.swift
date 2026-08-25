//
//  AffordabilityEngineTests.swift
//  PortfolioManager
//

import XCTest
@testable import PortfolioManager

final class AffordabilityEngineTests: XCTestCase {

    private func makeProfile(income: Double, expenses: Double, debt: Double = 0, savings: Double = 0) -> FinancialProfile {
        FinancialProfile(monthlyIncome: income, monthlyExpenses: expenses, monthlyDebtPayments: debt, currentSavings: savings)
    }

    // MARK: - disposableIncome

    func test_disposableIncome_subtractsExpensesAndDebt() {
        let result = AffordabilityEngine.disposableIncome(income: 3000, expenses: 1500, debtPayments: 500)
        XCTAssertEqual(result, 1000, accuracy: 0.001)
    }

    func test_disposableIncome_neverGoesNegative() {
        // Expenses + debt exceed income - should clamp to 0, not a negative number.
        let result = AffordabilityEngine.disposableIncome(income: 1000, expenses: 900, debtPayments: 300)
        XCTAssertEqual(result, 0)
    }

    func test_disposableIncome_zeroExpensesAndDebt() {
        let result = AffordabilityEngine.disposableIncome(income: 2000, expenses: 0, debtPayments: 0)
        XCTAssertEqual(result, 2000, accuracy: 0.001)
    }

    // MARK: - emergencyFundCoverageMonths

    func test_emergencyFundCoverageMonths_normalCase() {
        let profile = makeProfile(income: 3000, expenses: 1000, savings: 5000)
        // £5000 saved / £1000 monthly expenses = 5 months covered.
        XCTAssertEqual(AffordabilityEngine.emergencyFundCoverageMonths(profile), 5, accuracy: 0.001)
    }

    func test_emergencyFundCoverageMonths_zeroExpenses_returnsZero_notDivideByZero() {
        let profile = makeProfile(income: 3000, expenses: 0, savings: 5000)
        XCTAssertEqual(AffordabilityEngine.emergencyFundCoverageMonths(profile), 0)
    }

    func test_emergencyFundCoverageMonths_zeroSavings() {
        let profile = makeProfile(income: 3000, expenses: 1000, savings: 0)
        XCTAssertEqual(AffordabilityEngine.emergencyFundCoverageMonths(profile), 0)
    }

    // MARK: - safeMonthlyInvestment

    func test_safeMonthlyInvestment_belowThreeMonthsCoverage_returnsZero() {
        // £2000 savings / £1000 expenses = 2 months - below the 3-month threshold.
        let profile = makeProfile(income: 3000, expenses: 1000, savings: 2000)
        XCTAssertEqual(AffordabilityEngine.safeMonthlyInvestment(profile), 0)
    }

    func test_safeMonthlyInvestment_exactlyThreeMonthsCoverage_isSafe() {
        // Boundary case: guard is coverage >= 3, so exactly 3 months should pass, not fail.
        let profile = makeProfile(income: 3000, expenses: 1000, savings: 3000)
        let expectedDisposable = AffordabilityEngine.disposableIncome(income: 3000, expenses: 1000, debtPayments: 0)
        XCTAssertEqual(AffordabilityEngine.safeMonthlyInvestment(profile), expectedDisposable, accuracy: 0.001)
    }

    func test_safeMonthlyInvestment_aboveThreeMonthsCoverage_returnsFullDisposableIncome() {
        let profile = makeProfile(income: 4000, expenses: 1000, debt: 500, savings: 6000)
        // 6000/1000 = 6 months covered, well above the threshold.
        let expectedDisposable = AffordabilityEngine.disposableIncome(income: 4000, expenses: 1000, debtPayments: 500)
        XCTAssertEqual(AffordabilityEngine.safeMonthlyInvestment(profile), expectedDisposable, accuracy: 0.001)
    }
}
