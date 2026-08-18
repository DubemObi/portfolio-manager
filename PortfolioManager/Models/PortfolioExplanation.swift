//
//  PortfolioExplanation.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 13/08/2026.
//

import Foundation


/// Everything the explanation layer needs to know, already computed.
/// Neither provider touches raw Holding/FinancialProfile objects directly.
struct PortfolioExplanationInput {
    let totalValue: Double
    let currentAllocation: [AssetClass: Double]
    let rebalanceCandidates: [AssetClass: Double]
    let healthScore: HealthScore
    let disposableIncome: Double
    let staleHoldingNames: [String]
}

/// The shared result shape both providers return, so the UI never needs
/// to know which one actually produced it.
struct PortfolioExplanation {
    var overview: String
    var insights: [String]
    var recommendations: [String]
}


