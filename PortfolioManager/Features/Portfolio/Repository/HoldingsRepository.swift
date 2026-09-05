//
//  HoldingsRepository.swift
//  PortfolioManager
//

import SwiftData
import Foundation

/// Owns every direct ModelContext touch (insert/fetch/save) for Holding and
/// Contribution records. HoldingsViewModel keeps all orchestration, network
/// calls, and error-handling - this just does the persistence.
final class HoldingsRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    /// Inserts a new Holding and saves. Throws if the save fails.
    @discardableResult
    func add(
        name: String,
        symbol: String?,
        quantity: Double,
        assetClass: AssetClass,
        pricePerUnit: Double,
        lastUpdated: Date?
    ) throws -> Holding {
        let holding = Holding(
            name: name, symbol: symbol, quantity: quantity,
            pricePerUnit: pricePerUnit, lastUpdated: lastUpdated, assetClass: assetClass
        )
        context.insert(holding)
        try context.save()
        return holding
    }

    /// Sets a manually-valued holding's quantity and saves.
    func updateValue(holding: Holding, newValue: Double) throws {
        holding.quantity = newValue
        holding.lastUpdated = .now
        try context.save()
    }

    /// Sets a single holding's live price and saves.
    func updatePrice(holding: Holding, price: Double, updatedAt: Date) throws {
        holding.pricePerUnit = price
        holding.lastUpdated = updatedAt
        try context.save()
    }

    /// Applies price updates to several holdings and saves once, so a batch
    /// refresh commits atomically instead of one save per holding.
    func updatePrices(_ updates: [(holding: Holding, price: Double, updatedAt: Date)]) throws {
        for update in updates {
            update.holding.pricePerUnit = update.price
            update.holding.lastUpdated = update.updatedAt
        }
        try context.save()
    }

    /// Adds to a holding's quantity, records a Contribution, and saves.
    func recordContribution(holding: Holding, quantityAdded: Double) throws {
        holding.quantity += quantityAdded

        let record = Contribution(
            holdingName: holding.name,
            quantityAdded: quantityAdded,
            pricePerUnitAtContribution: holding.pricePerUnit
        )
        context.insert(record)
        try context.save()
    }

    /// Whether a Holding with this symbol already exists.
    func symbolExists(_ symbol: String) throws -> Bool {
        let existing = try context.fetch(FetchDescriptor<Holding>())
        return existing.contains { $0.symbol == symbol }
    }
    
    func delete(_ holding: Holding) throws {
        context.delete(holding)
        try context.save()
    }
}
