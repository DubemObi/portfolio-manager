//
//  DashboardView.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 27/07/2026.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    @State private var vm = DashboardViewModel()
    @State private var isShowingProfileEditor: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Portfolio Health") {
                    healthRow("Overall", vm.healthScore.overall)
                    healthRow("Diversification", vm.healthScore.diversification)
                    healthRow("Risk alignment", vm.healthScore.riskAlignment)
                }
                .listRowBackground(AppColors.card)
                
                Section("Financial Capacity") {
                    capacityRow("Monthly income", vm.profile?.monthlyIncome)
                    capacityRow("Expenses", vm.profile?.monthlyExpenses)
                    capacityRow("Debt payments", vm.profile?.monthlyDebtPayments)
                    capacityRow("Disposable income", vm.disposableIncome)
                }
                .listRowBackground(AppColors.card)
                
            }.scrollContentBackground(.hidden)
                .background(AppColors.background)
                .navigationTitle("Dashboard").toolbar {
                    Button {
                        isShowingProfileEditor = true
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                    
                }
            .sheet(isPresented: $isShowingProfileEditor) {
                OnboardingView()
            }
            .onAppear() {
                vm.load(context: context)
            }
            
            VStack{
                Text(colorScheme == .dark ? "DARK" : "LIGHT")

            }.frame(maxWidth: .infinity, maxHeight: .infinity).background(AppColors.categoryBackground)
            
            AIStreamingConversation()
        }
    }
    
    
    private func healthRow(_ label: String, _ value: Double) -> some View {
        HStack {
            Text(label).foregroundStyle(AppColors.textPrimary)
            Spacer()
            Text("\(Int(value))/100").foregroundStyle(AppColors.textSecondary)
        }
    }
    
    private func capacityRow(_ label: String, _ value: Double?) -> some View {
        HStack {
            Text(label).foregroundStyle(AppColors.textPrimary)
            Spacer()
            Text("£\(value ?? 0, specifier: "%.2f")").foregroundStyle(AppColors.textSecondary)
        }
    }
}
