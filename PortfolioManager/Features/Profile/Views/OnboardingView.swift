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

    @State private var currentStep = 0
    @State private var stepError: String?

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
    @State private var quizAnswers: [Int: RiskQuizOption] = [:]

    private let totalSteps = 4

    private var isEditingExisting: Bool { profiles.first != nil }

    private var computedRisk: FinancialProfile.RiskCategory? {
        let scores = (0..<RiskProfilingEngine.questions.count).compactMap { quizAnswers[$0]?.score }
        guard scores.count == RiskProfilingEngine.questions.count else { return nil }
        return RiskProfilingEngine.classify(scores: scores)
    }

    var body: some View {
        VStack(spacing: 0) {
            StepProgressHeader(title: "Financial profile", currentStep: currentStep, totalSteps: totalSteps)
                .padding()
                .background(AppColors.background)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    switch currentStep {
                    case 0: aboutYouStep
                    case 1: incomeExpensesStep
                    case 2: riskToleranceStep
                    default: goalsStep
                    }

                    if let stepError {
                        Text(stepError).font(.footnote).foregroundStyle(AppColors.warning)
                    }
                    if let errorMessage = vm.errorMessage {
                        Text(errorMessage).font(.footnote).foregroundStyle(AppColors.warning)
                    }
                }
                .padding()
            }

            navigationBar
        }
        .background(AppColors.background)
        .onAppear { loadExistingProfileIfNeeded() }
        .onChange(of: computedRisk) { _, newValue in
            if let newValue { selectedRisk = newValue }
        }
    }

    // MARK: - Steps

    private var aboutYouStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About you").font(.headline).foregroundStyle(AppColors.textPrimary)
            FormField(label: "Your name", text: $name)
        }
    }

    private var incomeExpensesStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Income and expenses").font(.headline).foregroundStyle(AppColors.textPrimary)
            Text("This helps us estimate how much you can safely invest each month.")
                .font(.caption).foregroundStyle(AppColors.textSecondary)

            FormField(label: "Monthly income", text: $income, keyboardType: .decimalPad)
            FormField(label: "Monthly expenses", text: $expenses, keyboardType: .decimalPad)
            FormField(label: "Monthly debt payments", text: $debtPayments, keyboardType: .decimalPad)
            FormField(label: "Current savings", text: $savings, keyboardType: .decimalPad)
        }
    }

    private var riskToleranceStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Risk tolerance").font(.headline).foregroundStyle(AppColors.textPrimary)
            riskQuizSection

            ChipPicker(
                title: "Your risk category",
                options: FinancialProfile.RiskCategory.allCases,
                displayName: { $0.displayName },
                selection: $selectedRisk
            )
            Text("Set automatically from your quiz answers above - adjust here if you disagree with the suggestion.")
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private var goalsStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your financial goal").font(.headline).foregroundStyle(AppColors.textPrimary)
            Text("We'll use this to personalise your plan and insights.")
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary)

            GoalCardPicker(selection: $selectedGoal)

            if selectedGoal == .somethingElse {
                FormField(label: "Tell us more", text: $customGoal)
            }

            FormField(label: "Target amount (£, optional)", text: $targetAmount, keyboardType: .decimalPad)
        }
    }

    private var riskQuizSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Answer these to get a suggested risk category based on your circumstances, not just a guess.")
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary)

            ForEach(Array(RiskProfilingEngine.questions.enumerated()), id: \.offset) { index, question in
                VStack(alignment: .leading, spacing: 6) {
                    Text(question.prompt)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.textPrimary)

                    VStack(spacing: 6) {
                        ForEach(question.options) { option in
                            let isSelected = quizAnswers[index]?.id == option.id
                            Button {
                                quizAnswers[index] = option
                            } label: {
                                HStack {
                                    Text(option.text).font(.footnote)
                                    Spacer()
                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(isSelected ? AppColors.brand.opacity(0.10) : AppColors.card)
                                .foregroundStyle(isSelected ? AppColors.brand : AppColors.textPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(isSelected ? AppColors.brand : AppColors.border, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            if let computedRisk {
                HStack(spacing: 8) {
                    Image(systemName: computedRisk.icon).foregroundStyle(computedRisk.color)
                    Text("Suggested: \(computedRisk.displayName) risk")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(computedRisk.color)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(computedRisk.colorBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: - Navigation

    private var navigationBar: some View {
        HStack(spacing: 12) {
            if currentStep > 0 {
                Button("Back") {
                    stepError = nil
                    currentStep -= 1
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(AppColors.card)
                .foregroundStyle(AppColors.textPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button(primaryButtonLabel) {
                advance()
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(AppColors.actionPrimary)
            .foregroundStyle(AppColors.actionPrimaryOn)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .background(AppColors.background)
    }

    private var primaryButtonLabel: String {
        guard currentStep == totalSteps - 1 else { return "Continue" }
        return isEditingExisting ? "Save changes" : "Finish"
    }

    private func advance() {
        stepError = nil

        if currentStep == 1 {
            guard Double(income) != nil, Double(expenses) != nil else {
                stepError = "Enter valid numbers for income and expenses."
                return
            }
        }

        if currentStep == totalSteps - 1 {
            if selectedGoal == .somethingElse && customGoal.trimmingCharacters(in: .whitespaces).isEmpty {
                stepError = "Tell us a bit about your goal, or pick one of the options above."
                return
            }
            saveProfile()
            return
        }

        currentStep += 1
    }

    private func saveProfile() {
        let saved = vm.saveProfile(
            name: name, income: income, expenses: expenses,
            debtPayments: debtPayments, savings: savings,
            risk: selectedRisk, goal: selectedGoal,
            customGoal: customGoal, targetAmount: targetAmount,
            context: context
        )
        if saved { dismiss() }
    }

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
