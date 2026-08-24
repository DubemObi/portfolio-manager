//
//  OnboardingView.swift
//  PortfolioManager
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [FinancialProfile]
    @State private var vm = ProfileViewModel()

    @State private var name: String = ""
    @State private var income: String = ""
    @State private var expenses: String = ""
    @State private var debtPayments: String = ""
    @State private var savings: String = ""
    @State private var selectedRisk: FinancialProfile.RiskCategory = .moderate
    @State private var selectedGoal: FinancialGoal = .longTermWealth
    @State private var customGoal: String = ""
    @State private var targetAmount: String = ""
    @State private var hasLoadedExistingProfile = false

    private var isEditingExisting: Bool { profiles.first != nil }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(isEditingExisting ? "Edit your financial profile" : "Your financial profile")
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

                if let errorMessage = vm.errorMessage {
                    Text(errorMessage).font(.footnote).foregroundStyle(AppColors.warning)
                }

                Button(isEditingExisting ? "Save changes" : "Continue") {
                    let saved = vm.saveProfile(
                        name: name, income: income, expenses: expenses,
                        debtPayments: debtPayments, savings: savings,
                        risk: selectedRisk, goal: selectedGoal,
                        customGoal: customGoal, targetAmount: targetAmount,
                        context: context
                    )
                    if saved { dismiss() }
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
        .onAppear { loadExistingProfileIfNeeded() }
    }

    /// Pre-fills the form from the existing profile when this view is
    /// reused as the edit screen. Guarded by hasLoadedExistingProfile so
    /// a sheet re-appearing (e.g. after a dismissed keyboard) never
    /// silently overwrites text the user is mid-way through editing.
    private func loadExistingProfileIfNeeded() {
        guard !hasLoadedExistingProfile, let profile = profiles.first else {
            hasLoadedExistingProfile = true
            return
        }

        name = profile.name
        income = String(format: "%.2f", profile.monthlyIncome)
        expenses = String(format: "%.2f", profile.monthlyExpenses)
        debtPayments = String(format: "%.2f", profile.monthlyDebtPayments)
        savings = String(format: "%.2f", profile.currentSavings)
        selectedRisk = profile.riskCategory
        selectedGoal = profile.financialGoal
        customGoal = profile.customGoalDescription ?? ""
        targetAmount = profile.targetAmount.map { String(format: "%.2f", $0) } ?? ""

        hasLoadedExistingProfile = true
    }
}
