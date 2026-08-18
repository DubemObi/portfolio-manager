//
//  ExplanationProvider.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 13/08/2026.
//

protocol ExplanationProvider {
    func explain(holdings: [Holding], profile: FinancialProfile) async -> PortfolioExplanation?
}
