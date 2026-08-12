//
//  OnboardingView.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 06/08/2026.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var context

    @State private var income: String = ""
    @State private var expenses: String = ""
    @State private var debtPayments: String = ""
    @State private var savings: String = ""
    
    @State private var selectedRisk: RiskCategory = .moderate

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Your financial profile")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                
                labeledField("Monthly income", text: $income)
                labeledField("Monthly expenses", text: $expenses)
                labeledField("Monthly debt payments", text: $debtPayments)
                labeledField("Current savings", text: $savings)
            
                riskPicker
                
                Button("Continue") {
                    saveProfile()
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(AppColors.actionPrimary)
                .foregroundStyle(AppColors.actionPrimaryText)
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

        let existingProfiles = try? context.fetch(FetchDescriptor<FinancialProfile>())

        if let existing = existingProfiles?.first {
            existing.monthlyIncome = incomeValue
            existing.monthlyExpenses = expensesValue
            existing.monthlyDebtPayments = debtValue
            existing.currentSavings = savingsValue
            existing.riskCategory = selectedRisk
        } else {
            let profile = FinancialProfile(
                monthlyIncome: incomeValue,
                monthlyExpenses: expensesValue,
                monthlyDebtPayments: debtValue,
                currentSavings: savingsValue,
                riskCategory: selectedRisk
            )
            context.insert(profile)
        }

        try? context.save()
    }
    

    private var riskPicker: some View {
           VStack(alignment: .leading, spacing: 8) {
               Text("Risk tolerance")
                   .font(.caption)
                   .foregroundStyle(AppColors.textSecondary)

               HStack(spacing: 8) {
                   ForEach(RiskCategory.allCases) { option in
                       riskOption(option)
                   }
               }
           }
       }

       private func riskOption(_ option: RiskCategory) -> some View {
           let isSelected = selectedRisk == option

           return Text(option.displayName)
               .font(.footnote)
               .padding(.horizontal, 12)
               .padding(.vertical, 6)
               .background(
                   isSelected
                       ? AppColors.categoryBackground
                       : AppColors.card
               )
               .foregroundStyle(
                   isSelected
                       ? AppColors.categoryText
                       : AppColors.textSecondary
               )
               .clipShape(Capsule())
               .overlay(
                   Capsule()
                       .stroke(AppColors.border, lineWidth: 0.5)
               )
               .onTapGesture {
                   selectedRisk = option
               }
       }

    
    private func labeledField(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)

            TextField("", text: text)
                .keyboardType(.decimalPad)
                .padding(10)
                .background(AppColors.card)
                .foregroundStyle(AppColors.textPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12).stroke(AppColors.border, lineWidth: 0.5)
                )
        }
    }
}
