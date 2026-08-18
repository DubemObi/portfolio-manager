//
//  Holdings.swift
//  PortfolioManager
//

import SwiftData
import Foundation

enum AssetClass: String, CaseIterable, Codable, Identifiable {
    case equities, bonds, cash, realEstate, commodities
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .equities: "Equities"
        case .bonds: "Bonds"
        case .cash: "Cash"
        case .realEstate: "Real Estate"
        case .commodities: "Commodities"
        }
    }
    var icon: String {
        switch self {
        case .equities: "chart.bar.fill"
        case .bonds: "building.columns.fill"
        case .cash: "banknote.fill"
        case .realEstate: "house.fill"
        case .commodities: "shippingbox.fill"
        }
    }
}

@Model
class Holding {
    var name: String
    var symbol: String?
    var quantity: Double = 0            // how many units you own - only changes on buy/sell
    var pricePerUnit: Double = 0  // live market price - only "Refresh Price" touches this
    var lastUpdated: Date?
    var assetClass: AssetClass = AssetClass.equities

    /// Calculated, never stored: always quantity × current price.
    /// This can never go stale the way a stored "value" could, for the
    /// exact same reason the health score can't - it's recomputed on
    /// every access, straight from the two real numbers underneath it.
    var value: Double {
        quantity * pricePerUnit
    }
    
    /// True if this holding has never been valued, or hasn't been
    /// updated in over 30 days - used to caveat AI/rule-based insights
    /// rather than presenting every figure as equally current.
    var isStale: Bool {
        guard let lastUpdated else { return true }
        return Date.now.timeIntervalSince(lastUpdated) > 60 * 60 * 24 * 30
    }

    init(name: String, symbol: String? = nil, quantity: Double, pricePerUnit: Double, lastUpdated: Date? = nil, assetClass: AssetClass = .equities) {
        self.name = name
        self.symbol = symbol
        self.quantity = quantity
        self.pricePerUnit = pricePerUnit
        self.lastUpdated = lastUpdated
        self.assetClass = assetClass
    }
}
