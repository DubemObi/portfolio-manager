//
//  AlertsEngine.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 18/08/2026.
//

import Foundation

struct AlertsEngine {

    /// Which currently-drifted asset classes actually need showing as a
    /// fresh alert - excluding ones recently decided on or still snoozed.
    static func pendingAlerts(
        candidates: [AssetClass: Double],
        decisions: [RebalanceDecision]
    ) -> [AssetClass: Double] {
        let now = Date.now

        return candidates.filter { assetClass, _ in
            let mostRecent = decisions
                .filter { $0.assetClass == assetClass }
                .sorted { $0.decidedAt > $1.decidedAt }
                .first

            guard let mostRecent else { return true }   // never decided on - show it

            switch mostRecent.decision {
            case .accepted, .declined:
                // Don't re-surface the same asset class for 30 days after a decision
                return now.timeIntervalSince(mostRecent.decidedAt) > 60 * 60 * 24 * 30
            case .snoozed:
                guard let snoozeUntil = mostRecent.snoozeUntil else { return true }
                return now >= snoozeUntil
            }
        }
    }
}
