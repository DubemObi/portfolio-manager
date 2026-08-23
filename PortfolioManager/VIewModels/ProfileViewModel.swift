//
//  ProfileViewModel.swift
//  PortfolioManager
//

import Foundation
import SwiftData

@Observable
final class ProfileViewModel {

    var errorMessage: String?

    /// Creates or updates the single FinancialProfile from raw form input.
    /// Returns true on success (caller should dismiss); false leaves the
    /// form open so the user can see errorMessage and correct it.
    @discardableResult
    func saveProfile(
        name: String,
        income: String,
        expenses: String,
        debtPayments: String,
        savings: String,
        risk: FinancialProfile.RiskCategory,
        goal: FinancialGoal,
        customGoal: String,
        targetAmount: String,
        context: ModelContext
    ) -> Bool {
        guard let incomeValue = Double(income), let expensesValue = Double(expenses) else {
            errorMessage = "Enter valid numbers for income and expenses."
            return false
        }

        let debtValue = Double(debtPayments) ?? 0
        let savingsValue = Double(savings) ?? 0
        let targetAmountValue = Double(targetAmount)
        let customGoalValue: String? = goal == .somethingElse ? customGoal : nil

        let existingProfiles = try? context.fetch(FetchDescriptor<FinancialProfile>())

        if let existing = existingProfiles?.first {
            existing.name = name
            existing.monthlyIncome = incomeValue
            existing.monthlyExpenses = expensesValue
            existing.monthlyDebtPayments = debtValue
            existing.currentSavings = savingsValue
            existing.riskCategory = risk
            existing.lastConfirmed = .now
            existing.lastRiskAssessment = .now
            existing.financialGoal = goal
            existing.customGoalDescription = customGoalValue
            existing.targetAmount = targetAmountValue
        } else {
            let profile = FinancialProfile(
                name: name,
                monthlyIncome: incomeValue,
                monthlyExpenses: expensesValue,
                monthlyDebtPayments: debtValue,
                currentSavings: savingsValue,
                riskCategory: risk,
                financialGoal: goal,
                customGoalDescription: customGoalValue,
                targetAmount: targetAmountValue
            )
            context.insert(profile)
        }

        do {
            try context.save()
        } catch {
            errorMessage = "Couldn't save your profile. Please try again."
            return false
        }

        Task {
            await NotificationScheduler.requestPermission()
            NotificationScheduler.scheduleCheckInReminder(from: .now)
            NotificationScheduler.scheduleRiskReminder(from: .now)
        }

        return true
    }
}
