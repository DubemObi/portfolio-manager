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

/// Which provider actually produced an explanation. The View uses this to
/// decide whether follow-up questions are offered - that feature is AI-only,
/// since RuleBasedExplanationProvider has no way to answer an open-ended question.
enum ExplanationSource {
    case ai
    case ruleBased
}

/// The shared result shape both providers return, so the UI never needs
/// to know *which* one produced it - except for source, used only to
/// decide whether to show follow-up question chips.
struct PortfolioExplanation {
    var overview: String
    var insights: [String]
    var recommendations: [String]
    var source: ExplanationSource
    var suggestedQuestions: [String] = []
}
