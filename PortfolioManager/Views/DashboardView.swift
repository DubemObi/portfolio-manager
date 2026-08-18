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
    @State private var vm = DashboardViewModel()
    @State private var isShowingProfileEditor = false
    
    @Query private var holdings: [Holding]
    @Query private var profiles: [FinancialProfile]

    private var profile: FinancialProfile? { profiles.first }

    private var healthScore: HealthScore {
        guard let profile else { return HealthScore(overall: 0, assetClassCoverage: 0, riskAlignment: 0) }
        return PortfolioHealthEngine.healthScore(holdings: holdings, profile: profile)
    }

    private var disposableIncome: Double {
        guard let profile else { return 0 }
        return AffordabilityEngine.disposableIncome(
                income: profile.monthlyIncome, expenses: profile.monthlyExpenses, debtPayments: profile.monthlyDebtPayments
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    heroCard

                    sectionCard(title: "Portfolio Health") {
                        row("Overall", vm.healthScore.overall)
                        row("Diversification", vm.healthScore.diversification)
                        row("Risk alignment", healthScore.riskAlignment)
                    }

                    sectionCard(title: "Financial Capacity") {
                        moneyRow("Monthly income", vm.profile?.monthlyIncome)
                        moneyRow("Expenses", vm.profile?.monthlyExpenses)
                        moneyRow("Debt payments", vm.profile?.monthlyDebtPayments)
                        moneyRow("Disposable income", disposableIncome)
                    }
                }
                .padding()
            }
            .background(AppColors.background)
            .navigationTitle("Dashboard")
            .toolbar {
                Button { isShowingProfileEditor = true } label: {
                    Image(systemName: "person.crop.circle")
                }
            }
            .sheet(isPresented: $isShowingProfileEditor) { OnboardingView() }
            .onAppear { vm.load(context: context) }
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "wallet.pass.fill")
                    .padding(8)
                    .background(AppColors.action)
                    .foregroundStyle(AppColors.actionOn)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Spacer()
                Text("PORTFOLIO").font(.caption2).foregroundStyle(.white.opacity(0.5))
            }
            Text("Total portfolio value").font(.caption).foregroundStyle(.white.opacity(0.6))
            Text("£\(vm.totalPortfolioValue, specifier: "%.2f")").font(.title).foregroundStyle(.white)
            Text("Health score \(Int(healthScore.overall))")
                .font(.caption).fontWeight(.semibold)
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(AppColors.action)
                .foregroundStyle(AppColors.actionOn)
                .clipShape(Capsule())
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.brand)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.caption).foregroundStyle(AppColors.textSecondary)
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func row(_ label: String, _ value: Double) -> some View {
        HStack {
            Text(label).foregroundStyle(AppColors.textPrimary)
            Spacer()
            Text("\(Int(value))/100").foregroundStyle(AppColors.textSecondary)
        }
    }

    private func moneyRow(_ label: String, _ value: Double?) -> some View {
        HStack {
            Text(label).foregroundStyle(AppColors.textPrimary)
            Spacer()
            Text("£\(value ?? 0, specifier: "%.2f")").foregroundStyle(AppColors.textSecondary)
        }
    }
}
