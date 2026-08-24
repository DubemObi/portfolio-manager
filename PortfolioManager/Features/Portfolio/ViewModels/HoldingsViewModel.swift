//
//  HoldingsViewModel.swift
//  PortfolioManager
//

import SwiftData
import Foundation

@Observable
class HoldingsViewModel {
    var lastErrorMessage: String?

    // MARK: - Add

    /// Creates a new Holding. For market-tracked holdings, attempts a
    /// best-effort live price fetch before saving (falls back to £0/nil
    /// if offline - non-blocking, matches the app's offline-first design).
    /// Returns true on success (caller should dismiss).
    @discardableResult
    func addHolding(
        name: String,
        symbol: String?,
        quantity: Double,
        assetClass: AssetClass,
        context: ModelContext
    ) async -> Bool {
        let repository = HoldingsRepository(context: context)

        let symbolToUse: String?
        let priceToUse: Double
        let lastUpdatedToUse: Date?

        if let symbol {
            let normalizedSymbol = symbol.uppercased()

            if (try? repository.symbolExists(normalizedSymbol)) == true {
                lastErrorMessage = "You already own \(normalizedSymbol). Update it from your Portfolio instead."
                return false
            }

            let result = await PriceService.fetchQuote(symbol: normalizedSymbol)
            let (price, lastUpdated): (Double, Date?) = {
                if case .success(let quote) = result { return (quote.c, .now) }
                return (0, nil)
            }()

            symbolToUse = normalizedSymbol
            priceToUse = price
            lastUpdatedToUse = lastUpdated
        } else {
            symbolToUse = nil
            priceToUse = 1
            lastUpdatedToUse = .now
        }

        do {
            try repository.add(
                name: name, symbol: symbolToUse, quantity: quantity,
                assetClass: assetClass, pricePerUnit: priceToUse, lastUpdated: lastUpdatedToUse
            )
        } catch {
            lastErrorMessage = "Couldn't save this holding. Please try again."
            return false
        }

        lastErrorMessage = nil
        return true
    }

    // MARK: - Update (manually-valued holdings)

    @discardableResult
    func updateValue(for holding: Holding, newValue: Double, context: ModelContext) -> Bool {
        let repository = HoldingsRepository(context: context)

        do {
            try repository.updateValue(holding: holding, newValue: newValue)
        } catch {
            lastErrorMessage = "Couldn't save this update. Please try again."
            return false
        }

        lastErrorMessage = nil
        return true
    }

    // MARK: - Refresh

    func refreshPrice(for holding: Holding, context: ModelContext) async {
        guard let symbol = holding.symbol else { return }
        let result = await PriceService.fetchQuote(symbol: symbol)

        switch result {
        case .success(let quote):
            let repository = HoldingsRepository(context: context)
            try? repository.updatePrice(holding: holding, price: quote.c, updatedAt: .now)
            lastErrorMessage = nil

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
        var updates: [(holding: Holding, price: Double, updatedAt: Date)] = []
        for holding in trackedHoldings {
            guard let symbol = holding.symbol, let result = results[symbol] else { continue }
            switch result {
            case .success(let quote):
                updates.append((holding, quote.c, .now))
            case .failure:
                failureCount += 1
            }
        }

        let repository = HoldingsRepository(context: context)
        try? repository.updatePrices(updates)

        lastErrorMessage = failureCount > 0
            ? "\(failureCount) of \(trackedHoldings.count) holdings couldn't be refreshed."
            : nil
    }

    // MARK: - Contribute

    func contribute(to holding: Holding, quantityToAdd: Double, context: ModelContext) {
        let repository = HoldingsRepository(context: context)
        try? repository.recordContribution(holding: holding, quantityAdded: quantityToAdd)
    }
}
