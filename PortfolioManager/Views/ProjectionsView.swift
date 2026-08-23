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
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Projected value in \(Int(years)) years")
                                .font(.caption).foregroundStyle(AppColors.textSecondary)
                            Text("£\(result.median, specifier: "%.0f")")
                                .font(.largeTitle).fontWeight(.semibold).foregroundStyle(AppColors.textPrimary)
                            Text("Range: £\(result.low, specifier: "%.0f") - £\(result.high, specifier: "%.0f")")
                                .font(.footnote).foregroundStyle(AppColors.textSecondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        if suggestedContribution > 0 {
                            Text("Based on your finances, you could safely invest up to £\(suggestedContribution, specifier: "%.0f")/month.")
                                .font(.footnote)
                                .foregroundStyle(AppColors.textSecondary)
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppColors.tint)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Monthly contribution").foregroundStyle(AppColors.textPrimary)
                                Spacer()
                                Text("£\(Int(monthlyContribution))").foregroundStyle(AppColors.textSecondary)
                            }
                            Slider(value: $monthlyContribution, in: 0...1000, step: 10)
                                .tint(AppColors.action)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Time horizon").foregroundStyle(AppColors.textPrimary)
                                Spacer()
                                Text("\(Int(years)) years").foregroundStyle(AppColors.textSecondary)
                            }
                            Slider(value: $years, in: 1...30, step: 1)
                                .tint(AppColors.action)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Assumed annual return")
                                .font(.caption).foregroundStyle(AppColors.textSecondary)
                            Text("\(Int(assumedReturn * 100))% - based on your \(profile.riskCategory.displayName.lowercased()) risk profile")
                                .font(.footnote).foregroundStyle(AppColors.textPrimary)
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
}
