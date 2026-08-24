//
//  AlertsRepository.swift
//  PortfolioManager
//

import SwiftData
import Foundation

/// Owns the direct ModelContext touches (insert/save) for RebalanceDecision.
final class AlertsRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    /// Inserts a new RebalanceDecision and saves. Throws if the save fails.
    func recordDecision(
        assetClass: AssetClass,
        drift: Double,
        healthScore: Double,
        decision: RebalanceDecision.Decision,
        snoozeUntil: Date?
    ) throws {
        let record = RebalanceDecision(
            assetClass: assetClass,
            driftAtDecision: drift,
            healthScoreAtDecision: healthScore,
            decision: decision,
            snoozeUntil: snoozeUntil
        )
        context.insert(record)
        try context.save()
    }
}
