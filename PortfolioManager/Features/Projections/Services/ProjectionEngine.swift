//
//  ProjectionEngine.swift
//  PortfolioManager
//

import Foundation

struct ProjectionEngine {

    struct ProjectionResult {
        var median: Double
        var low: Double
        var high: Double
    }

    /// Assumed average annual return per risk category - a deliberate
    /// simplification, not a researched or historically-validated figure.
    /// Worth stating plainly in the report as a stated assumption, not
    /// a claim of predictive accuracy.
    static func assumedAnnualReturn(for riskCategory: FinancialProfile.RiskCategory) -> Double {
        switch riskCategory {
        case .conservative: 0.04
        case .moderate: 0.06
        case .aggressive: 0.08
        }
    }

    static func project(
        currentValue: Double,
        monthlyContribution: Double,
        annualReturnRate: Double,
        years: Int
    ) -> ProjectionResult {

        func futureValue(rate: Double) -> Double {
            let monthlyRate = rate / 12
            let months = Double(years * 12)

            guard monthlyRate > 0 else {
                return currentValue + monthlyContribution * months
            }

            let growthFactor = pow(1 + monthlyRate, months)
            let principalGrowth = currentValue * growthFactor
            let contributionGrowth = monthlyContribution * ((growthFactor - 1) / monthlyRate)
            return principalGrowth + contributionGrowth
        }

        return ProjectionResult(
            median: futureValue(rate: annualReturnRate),
            low: futureValue(rate: max(0, annualReturnRate - 0.03)),
            high: futureValue(rate: annualReturnRate + 0.03)
        )
    }
}
