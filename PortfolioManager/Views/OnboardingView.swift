//
//  OnboardingView.swift
//  PortfolioManager
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var income: String = ""
    @State private var expenses: String = ""
    @State private var debtPayments: String = ""
    @State private var savings: String = ""
    @State private var selectedRisk: FinancialProfile.RiskCategory = .moderate
    @State private var selectedGoal: FinancialGoal = .longTermWealth
    @State private var customGoal: String = ""
    @State private var targetAmount: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Your financial profile")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)

                FormField(label: "Your name", text: $name)
                FormField(label: "Monthly income", text: $income, keyboardType: .decimalPad)
                FormField(label: "Monthly expenses", text: $expenses, keyboardType: .decimalPad)
                FormField(label: "Monthly debt payments", text: $debtPayments, keyboardType: .decimalPad)
                FormField(label: "Current savings", text: $savings, keyboardType: .decimalPad)

                ChipPicker(
                    title: "Risk tolerance",
                    options: FinancialProfile.RiskCategory.allCases,
                    displayName: { $0.displayName },
                    selection: $selectedRisk
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("What's your main financial goal?")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    Text("We'll use this to personalise your plan and insights.")
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)

                    GoalCardPicker(selection: $selectedGoal)

                    if selectedGoal == .somethingElse {
                        FormField(label: "Tell us more", text: $customGoal)
                    }
                }

                FormField(label: "Target amount (£, optional)", text: $targetAmount, keyboardType: .decimalPad)

                Button("Continue") {
                    saveProfile()
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(AppColors.actionPrimary)
                .foregroundStyle(AppColors.actionPrimaryOn)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .background(AppColors.background)
    }

    private func saveProfile() {
        guard
            let incomeValue = Double(income),
            let expensesValue = Double(expenses)
        else { return }

        let debtValue = Double(debtPayments) ?? 0
        let savingsValue = Double(savings) ?? 0
        let targetAmountValue = Double(targetAmount)
        let customGoalValue: String? = selectedGoal == .somethingElse ? customGoal : nil

        let existingProfiles = try? context.fetch(FetchDescriptor<FinancialProfile>())

        if let existing = existingProfiles?.first {
            existing.name = name
            existing.monthlyIncome = incomeValue
            existing.monthlyExpenses = expensesValue
            existing.monthlyDebtPayments = debtValue
            existing.currentSavings = savingsValue
            existing.riskCategory = selectedRisk
            existing.lastConfirmed = .now
            existing.lastRiskAssessment = .now
            existing.financialGoal = selectedGoal
            existing.customGoalDescription = customGoalValue
            existing.targetAmount = targetAmountValue
        } else {
            let profile = FinancialProfile(
                name: name,
                monthlyIncome: incomeValue,
                monthlyExpenses: expensesValue,
                monthlyDebtPayments: debtValue,
                currentSavings: savingsValue,
                riskCategory: selectedRisk,
                financialGoal: selectedGoal,
                customGoalDescription: customGoalValue,
                targetAmount: targetAmountValue
            )
            context.insert(profile)
        }

        try? context.save()

        Task {
            await NotificationScheduler.requestPermission()
            NotificationScheduler.scheduleCheckInReminder(from: .now)
            NotificationScheduler.scheduleRiskReminder(from: .now)
        }

        dismiss()
    }
}
