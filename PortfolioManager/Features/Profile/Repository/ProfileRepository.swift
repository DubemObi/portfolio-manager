//
//  ProfileRepository.swift
//  PortfolioManager
//

import SwiftData
import Foundation

/// Owns the direct ModelContext touches (fetch/insert/save) for
/// FinancialProfile. ProfileViewModel keeps input validation and
/// notification scheduling - this just does the persistence.
final class ProfileRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    /// Updates the single existing FinancialProfile, or inserts a new one if
    /// none exists yet, then saves. Throws if the save fails.
    func save(
        name: String,
        monthlyIncome: Double,
        monthlyExpenses: Double,
        monthlyDebtPayments: Double,
        currentSavings: Double,
        riskCategory: FinancialProfile.RiskCategory,
        financialGoal: FinancialGoal,
        customGoalDescription: String?,
        targetAmount: Double?
    ) throws {
        let existingProfiles = try context.fetch(FetchDescriptor<FinancialProfile>())

        if let existing = existingProfiles.first {
            existing.name = name
            existing.monthlyIncome = monthlyIncome
            existing.monthlyExpenses = monthlyExpenses
            existing.monthlyDebtPayments = monthlyDebtPayments
            existing.currentSavings = currentSavings
            existing.riskCategory = riskCategory
            existing.lastConfirmed = .now
            existing.lastRiskAssessment = .now
            existing.financialGoal = financialGoal
            existing.customGoalDescription = customGoalDescription
            existing.targetAmount = targetAmount
        } else {
            let profile = FinancialProfile(
                name: name,
                monthlyIncome: monthlyIncome,
                monthlyExpenses: monthlyExpenses,
                monthlyDebtPayments: monthlyDebtPayments,
                currentSavings: currentSavings,
                riskCategory: riskCategory,
                financialGoal: financialGoal,
                customGoalDescription: customGoalDescription,
                targetAmount: targetAmount
            )
            context.insert(profile)
        }

        try context.save()
    }
}
