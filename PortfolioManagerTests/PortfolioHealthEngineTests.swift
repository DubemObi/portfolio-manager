//
//  PortfolioHealthEngineTests.swift
//  PortfolioManager
//

import XCTest
@testable import PortfolioManager

final class PortfolioHealthEngineTests: XCTestCase {

    /// pricePerUnit fixed at 1 throughout, so quantity IS the £ value -
    /// keeps test data readable without a second multiplication to track.
    private func makeHolding(value: Double, assetClass: AssetClass, symbol: String? = "TEST") -> Holding {
        Holding(name: "Test Holding", symbol: symbol, quantity: value, pricePerUnit: 1, lastUpdated: .now, assetClass: assetClass)
    }

    private func makeProfile(risk: FinancialProfile.RiskCategory) -> FinancialProfile {
        FinancialProfile(monthlyIncome: 3000, monthlyExpenses: 1500, riskCategory: risk)
    }

    // MARK: - totalValue

    func test_totalValue_emptyPortfolio_isZero() {
        XCTAssertEqual(PortfolioHealthEngine.totalValue([]), 0)
    }

    func test_totalValue_sumsAllHoldings() {
        let holdings = [
            makeHolding(value: 1000, assetClass: .equities),
            makeHolding(value: 500, assetClass: .bonds),
            makeHolding(value: 250, assetClass: .cash)
        ]
        XCTAssertEqual(PortfolioHealthEngine.totalValue(holdings), 1750, accuracy: 0.001)
    }

    // MARK: - currentAllocation

    func test_currentAllocation_emptyPortfolio_returnsEmptyDictionary() {
        XCTAssertTrue(PortfolioHealthEngine.currentAllocation([]).isEmpty)
    }

    func test_currentAllocation_singleHolding_is100Percent() {
        let holdings = [makeHolding(value: 1000, assetClass: .equities)]
        let allocation = PortfolioHealthEngine.currentAllocation(holdings)
        XCTAssertEqual(allocation[.equities] ?? 0, 1.0, accuracy: 0.001)
        XCTAssertNil(allocation[.bonds])
    }

    func test_currentAllocation_multipleClasses_computesCorrectProportions() {
        let holdings = [
            makeHolding(value: 750, assetClass: .equities),
            makeHolding(value: 250, assetClass: .bonds)
        ]
        let allocation = PortfolioHealthEngine.currentAllocation(holdings)
        XCTAssertEqual(allocation[.equities] ?? 0, 0.75, accuracy: 0.001)
        XCTAssertEqual(allocation[.bonds] ?? 0, 0.25, accuracy: 0.001)
    }

    func test_currentAllocation_sameClass_holdingsAreCombined() {
        let holdings = [
            makeHolding(value: 300, assetClass: .equities, symbol: "AAA"),
            makeHolding(value: 200, assetClass: .equities, symbol: "BBB")
        ]
        let allocation = PortfolioHealthEngine.currentAllocation(holdings)
        XCTAssertEqual(allocation[.equities] ?? 0, 1.0, accuracy: 0.001)
    }

    // MARK: - drift

    func test_drift_includesEveryAssetClass_evenWhenZeroOnBothSides() {
        let drift = PortfolioHealthEngine.drift(current: [.equities: 0.5], target: [.equities: 0.5])
        // Every AssetClass case should appear in the result, not just .equities.
        XCTAssertEqual(drift.count, AssetClass.allCases.count)
        XCTAssertEqual(drift[.commodities] ?? -1, 0, accuracy: 0.001)
    }

    func test_drift_positiveWhenOverweight_negativeWhenUnderweight() {
        let drift = PortfolioHealthEngine.drift(current: [.equities: 0.70], target: [.equities: 0.50])
        XCTAssertEqual(drift[.equities] ?? 0, 0.20, accuracy: 0.001)

        let underweightDrift = PortfolioHealthEngine.drift(current: [.bonds: 0.10], target: [.bonds: 0.30])
        XCTAssertEqual(underweightDrift[.bonds] ?? 0, -0.20, accuracy: 0.001)
    }

    // MARK: - rebalanceCandidates

    func test_rebalanceCandidates_excludesDriftAtOrBelowThreshold() {
        let drift: [AssetClass: Double] = [.equities: 0.05, .bonds: 0.051]
        let candidates = PortfolioHealthEngine.rebalanceCandidates(drift: drift)
        // Exactly at the default 0.05 threshold should NOT be flagged (condition is strictly >).
        XCTAssertNil(candidates[.equities])
        XCTAssertNotNil(candidates[.bonds])
    }

    func test_rebalanceCandidates_respectsCustomThreshold() {
        let drift: [AssetClass: Double] = [.equities: 0.08]
        XCTAssertNil(PortfolioHealthEngine.rebalanceCandidates(drift: drift, threshold: 0.10)[.equities])
        XCTAssertNotNil(PortfolioHealthEngine.rebalanceCandidates(drift: drift, threshold: 0.05)[.equities])
    }

    // MARK: - healthScore

    func test_healthScore_emptyPortfolio_returnsAllZeros() {
        // Regression test for the empty-portfolio false-score bug found earlier
        // in the build - must not silently produce a nonzero score.
        let profile = makeProfile(risk: .moderate)
        let score = PortfolioHealthEngine.healthScore(holdings: [], profile: profile)
        XCTAssertEqual(score.overall, 0)
        XCTAssertEqual(score.assetClassCoverage, 0)
        XCTAssertEqual(score.riskAlignment, 0)
    }

    func test_healthScore_perfectlyMatchedAllocation_scoresMaximum() {
        // Moderate target: equities .50, bonds .30, cash .10, realEstate .05, commodities .05
        let profile = makeProfile(risk: .moderate)
        let holdings = [
            makeHolding(value: 5000, assetClass: .equities),
            makeHolding(value: 3000, assetClass: .bonds),
            makeHolding(value: 1000, assetClass: .cash),
            makeHolding(value: 500, assetClass: .realEstate),
            makeHolding(value: 500, assetClass: .commodities)
        ]
        let score = PortfolioHealthEngine.healthScore(holdings: holdings, profile: profile)
        XCTAssertEqual(score.assetClassCoverage, 100, accuracy: 0.001)
        XCTAssertEqual(score.riskAlignment, 100, accuracy: 0.001)
        XCTAssertEqual(score.overall, 100, accuracy: 0.001)
    }

    func test_healthScore_singleAssetClass_computesExpectedCoverageAndDrift() {
        // Conservative target: equities .25, bonds .50, cash .15, realEstate .05, commodities .05
        // Portfolio is 100% equities - deliberately far off target to hand-verify the maths.
        let profile = makeProfile(risk: .conservative)
        let holdings = [makeHolding(value: 1000, assetClass: .equities)]

        let score = PortfolioHealthEngine.healthScore(holdings: holdings, profile: profile)

        // Coverage: 1 of 5 asset classes held -> 1/5 * 100 = 20
        XCTAssertEqual(score.assetClassCoverage, 20, accuracy: 0.001)

        // Total absolute drift: |1.0-0.25| + |0-0.50| + |0-0.15| + |0-0.05| + |0-0.05| = 1.5
        // riskAlignment = 100 - (1.5 * 50) = 25
        XCTAssertEqual(score.riskAlignment, 25, accuracy: 0.001)

        // overall = (20 + 25) / 2 = 22.5
        XCTAssertEqual(score.overall, 22.5, accuracy: 0.001)
    }

    func test_healthScore_riskAlignment_neverGoesNegative() {
        // A maximally-drifted portfolio should floor at 0, not go negative.
        let profile = makeProfile(risk: .aggressive) // equities .70, bonds .10, cash .05, realEstate .10, commodities .05
        let holdings = [makeHolding(value: 1000, assetClass: .cash)] // 100% cash, everything else 0%
        let score = PortfolioHealthEngine.healthScore(holdings: holdings, profile: profile)
        XCTAssertGreaterThanOrEqual(score.riskAlignment, 0)
    }

    // MARK: - topHoldings / concentrationShare

    func test_topHoldings_returnsCorrectCountInDescendingOrder() {
        let holdings = [
            makeHolding(value: 100, assetClass: .cash, symbol: "A"),
            makeHolding(value: 500, assetClass: .equities, symbol: "B"),
            makeHolding(value: 300, assetClass: .bonds, symbol: "C")
        ]
        let top = PortfolioHealthEngine.topHoldings(holdings, limit: 2)
        XCTAssertEqual(top.count, 2)
        XCTAssertEqual(top[0].symbol, "B")
        XCTAssertEqual(top[1].symbol, "C")
    }

    func test_topHoldings_limitLargerThanHoldingsCount_returnsAllHoldings() {
        let holdings = [makeHolding(value: 100, assetClass: .cash)]
        XCTAssertEqual(PortfolioHealthEngine.topHoldings(holdings, limit: 5).count, 1)
    }

    func test_concentrationShare_emptyPortfolio_returnsZero_notDivideByZero() {
        XCTAssertEqual(PortfolioHealthEngine.concentrationShare([]), 0)
    }

    func test_concentrationShare_computesCorrectFraction() {
        let holdings = [
            makeHolding(value: 800, assetClass: .equities, symbol: "A"),
            makeHolding(value: 200, assetClass: .bonds, symbol: "B")
        ]
        // Top 1 holding (800) out of a 1000 total = 0.8
        XCTAssertEqual(PortfolioHealthEngine.concentrationShare(holdings, topCount: 1), 0.8, accuracy: 0.001)
    }
}
