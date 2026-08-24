//
//  DashboardView.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 27/07/2026.

import SwiftUI
import SwiftData

struct DashboardView: View {
    @State private var isShowingProfileEditor = false
    @State private var isShowingProfile = false

    @Query private var holdings: [Holding]
    @Query private var profiles: [FinancialProfile]

    private var profile: FinancialProfile? { profiles.first }

    private var totalPortfolioValue: Double {
        PortfolioHealthEngine.totalValue(holdings)
    }

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

    private struct DonutSlice: Identifiable {
        let id = UUID()
        let assetClass: AssetClass
        let percent: Double
        let start: Double
        let end: Double
    }

    private var donutSlices: [DonutSlice] {
        let sorted = PortfolioHealthEngine.currentAllocation(holdings).sorted { $0.value > $1.value }
        var cumulative: Double = 0
        var slices: [DonutSlice] = []
        for entry in sorted {
            let start = cumulative
            let end = cumulative + entry.value
            slices.append(DonutSlice(assetClass: entry.key, percent: entry.value, start: start, end: end))
            cumulative = end
        }
        return slices
    }

    private var topHoldings: [Holding] {
        PortfolioHealthEngine.topHoldings(holdings, limit: 5)
    }

    private var staleHoldings: [Holding] {
        holdings.filter(\.isStale)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let profile {
                        Text("Profile confirmed \(profile.lastConfirmed.formatted(.relative(presentation: .named)))")
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)

                        let daysSinceConfirmed = Calendar.current.dateComponents([.day], from: profile.lastConfirmed, to: .now).day ?? 0
                        let daysSinceRisk = Calendar.current.dateComponents([.day], from: profile.lastRiskAssessment, to: .now).day ?? 0

                        if daysSinceConfirmed > 90 {
                            reminderBanner("It's been \(daysSinceConfirmed) days - update your income and expenses.")
                        }
                        if daysSinceRisk > 180 {
                            reminderBanner("It's been over 6 months - re-check your risk tolerance still fits.")
                        }
                    }

                    heroCard

                    if !holdings.isEmpty {
                        sectionCard(title: "Allocation") {
                            HStack(alignment: .center, spacing: 20) {
                                ZStack {
                                    ForEach(donutSlices) { slice in
                                        Circle()
                                            .trim(from: slice.start, to: slice.end)
                                            .stroke(slice.assetClass.color, style: StrokeStyle(lineWidth: 24, lineCap: .butt))
                                            .rotationEffect(.degrees(-90))
                                    }
                                    VStack(spacing: 2) {
                                        Text("£\(totalPortfolioValue, specifier: "%.0f")")
                                            .font(.subheadline).fontWeight(.semibold)
                                            .foregroundStyle(AppColors.textPrimary)
                                        Text("Total").font(.caption2).foregroundStyle(AppColors.textSecondary)
                                    }
                                }
                                .frame(width: 110, height: 110)

                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(donutSlices) { slice in
                                        HStack(spacing: 6) {
                                            Circle()
                                                .fill(slice.assetClass.color)
                                                .frame(width: 8, height: 8)
                                            Text(slice.assetClass.displayName)
                                                .font(.caption)
                                                .foregroundStyle(AppColors.textPrimary)
                                            Spacer()
                                            Text("\(Int(slice.percent * 100))%")
                                                .font(.caption)
                                                .foregroundStyle(AppColors.textSecondary)
                                        }
                                    }
                                }
                            }
                        }

                        if let profile {
                            sectionCard(title: "Allocation vs Target") {
                                targetComparisonRows(profile: profile)
                            }
                        }
                    }

                    sectionCard(title: "Portfolio Health") {
                        row("Overall", healthScore.overall)
                        row("Diversification", healthScore.diversification)
                        row("Risk alignment", healthScore.riskAlignment)
                    }

                    if !topHoldings.isEmpty {
                        sectionCard(title: "Largest Holdings") {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(topHoldings, id: \.persistentModelID) { holding in
                                    HStack {
                                        Circle()
                                            .fill(holding.assetClass.color)
                                            .frame(width: 8, height: 8)
                                        Text(holding.name)
                                            .font(.footnote)
                                            .foregroundStyle(AppColors.textPrimary)
                                        Spacer()
                                        Text("£\(holding.value, specifier: "%.0f")")
                                            .font(.footnote)
                                            .foregroundStyle(AppColors.textSecondary)
                                        Text("\(Int((holding.value / max(totalPortfolioValue, 1)) * 100))%")
                                            .font(.caption2)
                                            .foregroundStyle(AppColors.textSecondary)
                                            .frame(width: 36, alignment: .trailing)
                                    }
                                }

                                Text("Top \(topHoldings.count) holdings make up \(Int(PortfolioHealthEngine.concentrationShare(holdings) * 100))% of your portfolio.")
                                    .font(.caption2)
                                    .foregroundStyle(AppColors.textSecondary)
                                    .padding(.top, 2)
                            }
                        }
                    }

                    if !holdings.isEmpty {
                        sectionCard(title: "Data Quality") {
                            dataQualityContent
                        }
                    }

                    sectionCard(title: "Financial Capacity") {
                        moneyRow("Monthly income", profile?.monthlyIncome)
                        moneyRow("Expenses", profile?.monthlyExpenses)
                        moneyRow("Debt payments", profile?.monthlyDebtPayments)
                        moneyRow("Disposable income", disposableIncome)
                    }
                }
                .padding()
            }
            .background(AppColors.background)
            .navigationTitle("Dashboard")
            .toolbar {
                Button { isShowingProfile = true } label: {
                    Image(systemName: "person.crop.circle.fill")
                }
            }
            .sheet(isPresented: $isShowingProfileEditor) {
                ThemedSheet { OnboardingView() }
            }
            .sheet(isPresented: $isShowingProfile) {
                ThemedSheet { ProfileView() }
            }
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
            Text("£\(totalPortfolioValue, specifier: "%.2f")").font(.title).foregroundStyle(.white)
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

    private func targetComparisonRows(profile: FinancialProfile) -> some View {
        let current = PortfolioHealthEngine.currentAllocation(holdings)
        let target = profile.riskCategory.targetAllocation
        let driftValues = PortfolioHealthEngine.drift(current: current, target: target)
        let relevantClasses = AssetClass.allCases.filter { (current[$0] ?? 0) > 0 || (target[$0] ?? 0) > 0 }

        return VStack(spacing: 14) {
            ForEach(relevantClasses) { assetClass in
                let actual = current[assetClass] ?? 0
                let targetPercent = target[assetClass] ?? 0
                let isAligned = abs(driftValues[assetClass] ?? 0) <= 0.05

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(assetClass.displayName)
                            .font(.footnote)
                            .foregroundStyle(AppColors.textPrimary)
                        Image(systemName: isAligned ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(isAligned ? AppColors.success : AppColors.warning)
                            .font(.caption2)
                        Spacer()
                        Text("\(Int(actual * 100))% · Target \(Int(targetPercent * 100))%")
                            .font(.caption2)
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppColors.tint)
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(assetClass.color)
                                .frame(width: geo.size.width * actual, height: 8)
//                            RoundedRectangle(cornerRadius: 4)
//                                .fill(AppColors.brand)
//                                .frame(width: geo.size.width * actual, height: 8)
                            Rectangle()
                                .fill(AppColors.textSecondary)
                                .frame(width: 2, height: 14)
                                .offset(x: max(0, geo.size.width * targetPercent - 1), y: -3)
                        }
                    }
                    .frame(height: 14)
                }
            }
        }
    }

    private var dataQualityContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            if staleHoldings.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(AppColors.success)
                    Text("All \(holdings.count) holdings recently valued.")
                        .font(.footnote)
                        .foregroundStyle(AppColors.textPrimary)
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(AppColors.warning)
                    Text("\(staleHoldings.count) of \(holdings.count) holdings haven't been updated recently.")
                        .font(.footnote)
                        .foregroundStyle(AppColors.textPrimary)
                }

                ForEach(staleHoldings, id: \.persistentModelID) { holding in
                    HStack {
                        Text(holding.name).font(.caption2).foregroundStyle(AppColors.textSecondary)
                        Spacer()
                        Text(staleDescription(for: holding)).font(.caption2).foregroundStyle(AppColors.textSecondary)
                    }
                }

                Text("Portfolio value may be less reliable until these are refreshed.")
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.top, 2)
            }
        }
    }

    private func staleDescription(for holding: Holding) -> String {
        guard let lastUpdated = holding.lastUpdated else { return "Never valued" }
        let days = Calendar.current.dateComponents([.day], from: lastUpdated, to: .now).day ?? 0
        return "Last valued \(days)d ago"
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

    private func reminderBanner(_ text: String) -> some View {
        Button { isShowingProfileEditor = true } label: {
            Text(text).font(.footnote).foregroundStyle(AppColors.warning)
                .padding(10).frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.warningBackground).clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
