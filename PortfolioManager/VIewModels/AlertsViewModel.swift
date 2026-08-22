//
//  AlertsViewModel.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 19/08/2026.
//

import SwiftData
import Foundation

@Observable
class AlertsViewModel {
    func recordDecision(
        assetClass: AssetClass,
        drift: Double,
        healthScore: Double,
        decision: RebalanceDecision.Decision,
        context: ModelContext
    ) {
        let snoozeUntil: Date? = decision == .snoozed ? Calendar.current.date(byAdding: .day, value: 7, to: .now) : nil

        let record = RebalanceDecision(
            assetClass: assetClass,
            driftAtDecision: drift,
            healthScoreAtDecision: healthScore,
            decision: decision,
            snoozeUntil: snoozeUntil
        )
        context.insert(record)
        try? context.save()
    }
}
