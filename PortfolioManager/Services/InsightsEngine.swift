//
//  InsightsEngine.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 13/08/2026.
//

struct InsightsEngine {
    static func generate(holdings: [Holding], profile: FinancialProfile) async -> PortfolioExplanation {
        if let aiResult = await OnDeviceAIExplanationProvider().explain(holdings: holdings, profile: profile) {
            return aiResult
        }
        return await RuleBasedExplanationProvider().explain(holdings: holdings, profile: profile)
            ?? PortfolioExplanation(overview: "Unable to generate insights right now.", insights: [], recommendations: [])
    }
}
