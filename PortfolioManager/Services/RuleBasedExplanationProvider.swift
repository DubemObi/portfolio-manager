//
//  RuleBasedExplanationProvider.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 13/08/2026.
//

import Foundation

struct RuleBasedExplanationProvider: ExplanationProvider {
    func explain(holdings: [Holding], profile: FinancialProfile) async -> PortfolioExplanation? {
        let current = PortfolioHealthEngine.currentAllocation(holdings)
        let target = profile.riskCategory.targetAllocation
        let driftValues = PortfolioHealthEngine.drift(current: current, target: target)
        let candidates = PortfolioHealthEngine.rebalanceCandidates(drift: driftValues)
        let score = PortfolioHealthEngine.healthScore(holdings: holdings, profile: profile)

        let overview = "Your portfolio is worth £\(String(format: "%.2f", PortfolioHealthEngine.totalValue(holdings))), with a health score of \(Int(score.overall))/100."

        let insights = current.sorted(by: { $0.value > $1.value }).map { assetClass, percent in
            "\(assetClass.displayName) makes up \(Int(percent * 100))% of your portfolio."
        }

        var recommendations: [String] = []
        for (assetClass, drift) in candidates.sorted(by: { abs($0.value) > abs($1.value) }) {
            let direction = drift > 0 ? "reducing" : "increasing"
            recommendations.append("Consider \(direction) your \(assetClass.displayName) allocation to better match your risk profile.")
        }
        if recommendations.isEmpty {
            recommendations.append("Your allocation is closely aligned with your target - no rebalancing needed right now.")
        }

        let staleNames = holdings.filter(\.isStale).map(\.name) ///\.isStale instead of { $0.isStale }
        if !staleNames.isEmpty {
            recommendations.append("Note: \(staleNames.joined(separator: ", ")) haven't been updated recently - these figures may be out of date.")
        }

        return PortfolioExplanation(overview: overview, insights: insights, recommendations: recommendations)
    }
}
