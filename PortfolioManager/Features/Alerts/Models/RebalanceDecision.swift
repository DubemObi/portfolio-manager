//
//  RebalanceDecision.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 18/08/2026.
//

import SwiftData
import Foundation

@Model
class RebalanceDecision {
    var id: UUID = UUID()
    var assetClass: AssetClass = AssetClass.equities
    var driftAtDecision: Double = 0
    var healthScoreAtDecision: Double = 0
    var decision: Decision = Decision.accepted
    var decidedAt: Date = Date.now
    var snoozeUntil: Date?

    enum Decision: String, Codable {
        case accepted, declined, snoozed
    }

    init(assetClass: AssetClass, driftAtDecision: Double, healthScoreAtDecision: Double, decision: Decision, snoozeUntil: Date? = nil) {
        self.assetClass = assetClass
        self.driftAtDecision = driftAtDecision
        self.healthScoreAtDecision = healthScoreAtDecision
        self.decision = decision
        self.decidedAt = .now
        self.snoozeUntil = snoozeUntil
    }
}
