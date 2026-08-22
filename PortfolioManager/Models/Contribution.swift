//
//  Contribution.swift
//  PortfolioManager
//

import SwiftData
import Foundation

@Model
class Contribution {
    var holdingName: String = ""
    var quantityAdded: Double = 0
    var pricePerUnitAtContribution: Double = 0
    var date: Date = Date.now

    /// Informational only - an estimate based on whatever price was
    /// known at the time, not a live-fetched figure.
    var estimatedAmount: Double {
        quantityAdded * pricePerUnitAtContribution
    }

    init(holdingName: String, quantityAdded: Double, pricePerUnitAtContribution: Double) {
        self.holdingName = holdingName
        self.quantityAdded = quantityAdded
        self.pricePerUnitAtContribution = pricePerUnitAtContribution
        self.date = .now
    }
}
