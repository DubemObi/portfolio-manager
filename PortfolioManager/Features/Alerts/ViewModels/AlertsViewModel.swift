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
    var lastErrorMessage: String?

    func recordDecision(
        assetClass: AssetClass,
        drift: Double,
        healthScore: Double,
        decision: RebalanceDecision.Decision,
        context: ModelContext
    ) {
        let snoozeUntil: Date? = decision == .snoozed ? Calendar.current.date(byAdding: .day, value: 7, to: .now) : nil

        let repository = AlertsRepository(context: context)
        do {
            try repository.recordDecision(
                assetClass: assetClass,
                drift: drift,
                healthScore: healthScore,
                decision: decision,
                snoozeUntil: snoozeUntil
            )
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = "Couldn't save your decision. Please try again."
        }
    }
}
