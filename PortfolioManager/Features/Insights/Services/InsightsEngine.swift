//
//  InsightsEngine.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 13/08/2026.
//

struct InsightsEngine {
    /// Takes the AI provider in rather than creating one, so the caller
    /// (InsightsViewModel) can hold onto that same instance afterward and
    /// reuse its session for follow-up questions.
    static func generate(
        aiProvider: OnDeviceAIExplanationProvider,
        holdings: [Holding],
        profile: FinancialProfile
    ) async -> PortfolioExplanation {
        if let aiResult = await aiProvider.explain(holdings: holdings, profile: profile) {
            return aiResult
        }
        return await RuleBasedExplanationProvider().explain(holdings: holdings, profile: profile)
            ?? PortfolioExplanation(overview: "Unable to generate insights right now.", insights: [], recommendations: [], source: .ruleBased)
    }
}
