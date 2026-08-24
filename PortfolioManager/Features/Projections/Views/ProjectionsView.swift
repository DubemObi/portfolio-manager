//
//  ProjectionsView.swift
//  PortfolioManager
//

import SwiftUI
import SwiftData

struct ProjectionsView: View {
    @Query private var holdings: [Holding]
    @Query private var profiles: [FinancialProfile]

    @State private var monthlyContribution: Double = 150
    @State private var years: Double = 15
    @State private var hasSetInitialContribution = false

    private var profile: FinancialProfile? { profiles.first }
    private var currentValue: Double { PortfolioHealthEngine.totalValue(holdings) }

    private var suggestedContribution: Double {
        guard let profile else { return 0 }
        return AffordabilityEngine.safeMonthlyInvestment(profile)
    }

    private var assumedReturn: Double {
        guard let profile else { return 0.06 }
        return ProjectionEngine.assumedAnnualReturn(for: profile.riskCategory)
    }

    private var result: ProjectionEngine.ProjectionResult {
        ProjectionEngine.project(
            currentValue: currentValue,
            monthlyContribution: monthlyContribution,
            annualReturnRate: assumedReturn,
            years: Int(years)
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let profile {
                    VStack(alignment: .leading, spacing: 16) {
                        heroCard

                        if suggestedContribution > 0 {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.caption)
                                    .foregroundStyle(AppColors.brand)
                                Text("Based on your finances, you could safely invest up to £\(suggestedContribution, specifier: "%.0f")/month.")
                                    .font(.footnote)
                                    .foregroundStyle(AppColors.textPrimary)
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppColors.brand.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        sectionCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Monthly contribution").foregroundStyle(AppColors.textPrimary)
                                    Spacer()
                                    Text("£\(Int(monthlyContribution))").foregroundStyle(AppColors.textSecondary)
                                }
                                Slider(value: $monthlyContribution, in: 0...1000, step: 10)
                                    .tint(AppColors.brand)
                            }
                        }

                        sectionCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Time horizon").foregroundStyle(AppColors.textPrimary)
                                    Spacer()
                                    Text("\(Int(years)) years").foregroundStyle(AppColors.textSecondary)
                                }
                                Slider(value: $years, in: 1...30, step: 1)
                                    .tint(AppColors.brand)
                            }
                        }

                        sectionCard {
                            HStack {
                                Image(systemName: profile.riskCategory.icon)
                                    .foregroundStyle(profile.riskCategory.color)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Assumed annual return")
                                        .font(.caption)
                                        .foregroundStyle(AppColors.textSecondary)
                                    Text("Based on your \(profile.riskCategory.displayName.lowercased()) risk profile")
                                        .font(.caption2)
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                                Spacer()
                                Text("\(Int(assumedReturn * 100))%")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 10).padding(.vertical, 4)
                                    .background(profile.riskCategory.colorBackground)
                                    .foregroundStyle(profile.riskCategory.color)
                                    .clipShape(Capsule())
                            }
                        }

                        Text("This is a simplified projection based on a fixed assumed annual return, not a market simulation. Actual results will vary.")
                            .font(.caption2)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding()
                } else {
                    EmptyStateView(icon: "chart.line.uptrend.xyaxis", message: "Complete your financial profile to see projections.")
                }
            }
            .background(AppColors.background)
            .navigationTitle("Projections")
            .onAppear {
                if !hasSetInitialContribution, suggestedContribution > 0 {
                    monthlyContribution = suggestedContribution
                    hasSetInitialContribution = true
                }
            }
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .padding(8)
                    .background(AppColors.action)
                    .foregroundStyle(AppColors.actionOn)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Spacer()
                Text("PROJECTION").font(.caption2).foregroundStyle(.white.opacity(0.5))
            }
            Text("Projected value in \(Int(years)) years").font(.caption).foregroundStyle(.white.opacity(0.6))
            Text("£\(result.median, specifier: "%.0f")").font(.title).foregroundStyle(.white)
            Text("Range £\(result.low, specifier: "%.0f") - £\(result.high, specifier: "%.0f")")
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

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
