//
//  PortfolioViewModel.swift
//  PortfolioManager
//

import SwiftData
import Foundation

@Observable
class PortfolioViewModel {
    var lastErrorMessage: String?

    func refreshPrice(for holding: Holding, context: ModelContext) async {
        guard let symbol = holding.symbol else { return }
        let result = await PriceService.fetchQuote(symbol: symbol)

        switch result {
        case .success(let quote):
            holding.pricePerUnit = quote.c
            holding.lastUpdated = .now
            lastErrorMessage = nil
            try? context.save()

        case .failure(.noInternet):
            lastErrorMessage = "You're offline - showing last known price."
        case .failure(.badResponse), .failure(.decodingFailed):
            lastErrorMessage = "Couldn't refresh price - showing last known price."
        }
    }

    /// Adding to an existing holding - quantity-based, no network needed,
    /// so this always succeeds instantly regardless of connectivity.
    /// Deliberately does NOT touch pricePerUnit or lastUpdated - only an
    /// actual price refresh should ever update those.
    func contribute(to holding: Holding, quantityToAdd: Double, context: ModelContext) {
        holding.quantity += quantityToAdd

        let record = Contribution(
            holdingName: holding.name,
            quantityAdded: quantityToAdd,
            pricePerUnitAtContribution: holding.pricePerUnit
        )
        context.insert(record)
        try? context.save()
    }
}
