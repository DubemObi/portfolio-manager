//
//  InsightsViewModel.swift
//  PortfolioManager
//

import Foundation

@Observable
class InsightsViewModel {
    var explanation: PortfolioExplanation?
    var isLoading = false

    func generate(holdings: [Holding], profile: FinancialProfile) async {
        isLoading = true
        defer { isLoading = false }

        explanation = await InsightsEngine.generate(holdings: holdings, profile: profile)
    }
}
