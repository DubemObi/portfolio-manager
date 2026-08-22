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

    /// Refreshes every market-tracked holding at once. Network fetches run
    /// concurrently (fast); only plain Strings cross into the concurrent
    /// tasks, never the Holding objects themselves. Mutations happen
    /// afterward, one at a time, once it's safe to touch stored data again.
    func refreshAllPrices(holdings: [Holding], context: ModelContext) async {
        let trackedHoldings = holdings.filter { $0.symbol != nil }
        guard !trackedHoldings.isEmpty else { return }

        let symbols = trackedHoldings.compactMap { $0.symbol }

        let results = await withTaskGroup(of: (String, Result<FinnhubQuote, PriceFetchError>).self) { group in
            for symbol in symbols {
                group.addTask {
                    let result = await PriceService.fetchQuote(symbol: symbol)
                    return (symbol, result)
                }
            }

            var collected: [String: Result<FinnhubQuote, PriceFetchError>] = [:]
            for await (symbol, result) in group {
                collected[symbol] = result
            }
            return collected
        }

        var failureCount = 0
        for holding in trackedHoldings {
            guard let symbol = holding.symbol, let result = results[symbol] else { continue }
            switch result {
            case .success(let quote):
                holding.pricePerUnit = quote.c
                holding.lastUpdated = .now
            case .failure:
                failureCount += 1
            }
        }

        try? context.save()

        lastErrorMessage = failureCount > 0
            ? "\(failureCount) of \(trackedHoldings.count) holdings couldn't be refreshed."
            : nil
    }

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
