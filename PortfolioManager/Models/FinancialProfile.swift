//
//  FinancialProfile.swift
//  PortfolioManager
//

import SwiftData
import SwiftUI

@Model
class FinancialProfile {
    var name: String = ""
    var monthlyIncome: Double
    var monthlyExpenses: Double
    var monthlyDebtPayments: Double = 0
    var currentSavings: Double = 0
    var riskCategory: RiskCategory = RiskCategory.moderate
    var lastConfirmed: Date = Date.now
    var lastRiskAssessment: Date = Date.now
    var financialGoal: FinancialGoal = FinancialGoal.longTermWealth
    var customGoalDescription: String?
    var targetAmount: Double?

    enum RiskCategory: String, CaseIterable, Codable, Identifiable {
        case conservative, moderate, aggressive

        var id: String { rawValue }
        var displayName: String { rawValue.capitalized }

        var targetAllocation: [AssetClass: Double] {
            switch self {
            case .conservative:
                return [.equities: 0.25, .bonds: 0.50, .cash: 0.15, .realEstate: 0.05, .commodities: 0.05]
            case .moderate:
                return [.equities: 0.50, .bonds: 0.30, .cash: 0.10, .realEstate: 0.05, .commodities: 0.05]
            case .aggressive:
                return [.equities: 0.70, .bonds: 0.10, .cash: 0.05, .realEstate: 0.10, .commodities: 0.05]
            }
        }
    }

    init(
        name: String = "",
        monthlyIncome: Double,
        monthlyExpenses: Double,
        monthlyDebtPayments: Double = 0,
        currentSavings: Double = 0,
        riskCategory: RiskCategory = .moderate,
        financialGoal: FinancialGoal = .longTermWealth,
        customGoalDescription: String? = nil,
        targetAmount: Double? = nil
    ) {
        self.name = name
        self.monthlyIncome = monthlyIncome
        self.monthlyExpenses = monthlyExpenses
        self.monthlyDebtPayments = monthlyDebtPayments
        self.currentSavings = currentSavings
        self.riskCategory = riskCategory
        self.lastConfirmed = .now
        self.lastRiskAssessment = .now
        self.financialGoal = financialGoal
        self.customGoalDescription = customGoalDescription
        self.targetAmount = targetAmount
    }
}
