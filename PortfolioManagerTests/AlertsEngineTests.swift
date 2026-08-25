//
//  AlertsEngineTests.swift
//  PortfolioManager
//

import XCTest
@testable import PortfolioManager

final class AlertsEngineTests: XCTestCase {

    private func makeDecision(
        assetClass: AssetClass,
        decision: RebalanceDecision.Decision,
        daysAgo: Double = 0,
        snoozeUntil: Date? = nil
    ) -> RebalanceDecision {
        let record = RebalanceDecision(
            assetClass: assetClass,
            driftAtDecision: 0.10,
            healthScoreAtDecision: 50,
            decision: decision,
            snoozeUntil: snoozeUntil
        )
        record.decidedAt = Date.now.addingTimeInterval(-daysAgo * 24 * 60 * 60)
        return record
    }

    func test_pendingAlerts_neverDecided_isIncluded() {
        let candidates: [AssetClass: Double] = [.equities: 0.10]
        let pending = AlertsEngine.pendingAlerts(candidates: candidates, decisions: [])
        XCTAssertNotNil(pending[.equities])
    }

    func test_pendingAlerts_notAmongCandidates_isNeverShown() {
        // AlertsEngine only ever filters what's already a candidate - an asset
        // class not passed in shouldn't appear even with no decisions at all.
        let pending = AlertsEngine.pendingAlerts(candidates: [.bonds: 0.10], decisions: [])
        XCTAssertNil(pending[.equities])
    }

    func test_pendingAlerts_acceptedRecently_isSuppressed() {
        let decision = makeDecision(assetClass: .equities, decision: .accepted, daysAgo: 5)
        let pending = AlertsEngine.pendingAlerts(candidates: [.equities: 0.10], decisions: [decision])
        XCTAssertNil(pending[.equities])
    }

    func test_pendingAlerts_declinedRecently_isSuppressed() {
        let decision = makeDecision(assetClass: .equities, decision: .declined, daysAgo: 5)
        let pending = AlertsEngine.pendingAlerts(candidates: [.equities: 0.10], decisions: [decision])
        XCTAssertNil(pending[.equities])
    }

    func test_pendingAlerts_acceptedOver30DaysAgo_reappears() {
        let decision = makeDecision(assetClass: .equities, decision: .accepted, daysAgo: 31)
        let pending = AlertsEngine.pendingAlerts(candidates: [.equities: 0.10], decisions: [decision])
        XCTAssertNotNil(pending[.equities])
    }

    func test_pendingAlerts_justUnder30Days_isStillSuppressed() {
        // 29.99 days ago - comfortably inside the 30-day window, with enough
        // margin (~14 minutes) that normal test execution speed can't
        // accidentally push this over the line.
        let decision = makeDecision(assetClass: .equities, decision: .accepted, daysAgo: 29.99)
        let pending = AlertsEngine.pendingAlerts(candidates: [.equities: 0.10], decisions: [decision])
        XCTAssertNil(pending[.equities])
    }

    func test_pendingAlerts_justOver30Days_reappears() {
        // 30.01 days ago - comfortably past the 30-day window, same margin
        // reasoning as above but on the other side of the boundary.
        let decision = makeDecision(assetClass: .equities, decision: .accepted, daysAgo: 30.01)
        let pending = AlertsEngine.pendingAlerts(candidates: [.equities: 0.10], decisions: [decision])
        XCTAssertNotNil(pending[.equities])
    }
    
    func test_pendingAlerts_snoozedWithFutureDate_isSuppressed() {
        let futureDate = Date.now.addingTimeInterval(60 * 60 * 24 * 3) // 3 days from now
        let decision = makeDecision(assetClass: .bonds, decision: .snoozed, snoozeUntil: futureDate)
        let pending = AlertsEngine.pendingAlerts(candidates: [.bonds: 0.10], decisions: [decision])
        XCTAssertNil(pending[.bonds])
    }

    func test_pendingAlerts_snoozeExpired_reappears() {
        let pastDate = Date.now.addingTimeInterval(-60 * 60 * 24) // 1 day ago
        let decision = makeDecision(assetClass: .bonds, decision: .snoozed, snoozeUntil: pastDate)
        let pending = AlertsEngine.pendingAlerts(candidates: [.bonds: 0.10], decisions: [decision])
        XCTAssertNotNil(pending[.bonds])
    }

    func test_pendingAlerts_snoozedWithNoSnoozeDate_isIncluded() {
        // Defensive case: snoozed but somehow has no snoozeUntil - code treats
        // this as "show it" rather than crashing or hiding it forever.
        let decision = makeDecision(assetClass: .bonds, decision: .snoozed, snoozeUntil: nil)
        let pending = AlertsEngine.pendingAlerts(candidates: [.bonds: 0.10], decisions: [decision])
        XCTAssertNotNil(pending[.bonds])
    }

    func test_pendingAlerts_onlyMostRecentDecisionMatters() {
        // An old declined decision followed by a more recent accepted one -
        // the recent one should govern, not the older one.
        let oldDecision = makeDecision(assetClass: .equities, decision: .declined, daysAgo: 40)
        let recentDecision = makeDecision(assetClass: .equities, decision: .accepted, daysAgo: 2)
        let pending = AlertsEngine.pendingAlerts(candidates: [.equities: 0.10], decisions: [oldDecision, recentDecision])
        // Recent (2 days ago, accepted) should suppress it - if the old one
        // were mistakenly used instead, this would be reversed.
        XCTAssertNil(pending[.equities])
    }

    func test_pendingAlerts_decisionsForOtherAssetClasses_areIgnored() {
        let decision = makeDecision(assetClass: .bonds, decision: .accepted, daysAgo: 1)
        let pending = AlertsEngine.pendingAlerts(candidates: [.equities: 0.10], decisions: [decision])
        // The recent decision is for .bonds, not .equities - shouldn't affect this candidate.
        XCTAssertNotNil(pending[.equities])
    }
}
