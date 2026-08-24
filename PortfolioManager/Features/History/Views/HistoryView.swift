//
//  HistoryView.swift
//  PortfolioManager
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \Contribution.date, order: .reverse) private var contributions: [Contribution]

    var body: some View {
        NavigationStack {
            Group {
                if contributions.isEmpty {
                    EmptyStateView(icon: "clock.arrow.circlepath", message: "No contributions logged yet.")
                } else {
                    List(contributions) { contribution in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(contribution.holdingName)
                                    .font(.subheadline).fontWeight(.semibold)
                                    .foregroundStyle(AppColors.textPrimary)
                                Spacer()
                                Text(contribution.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption2).foregroundStyle(AppColors.textSecondary)
                            }
                            Text("+\(contribution.quantityAdded, specifier: "%.4f") units at £\(contribution.pricePerUnitAtContribution, specifier: "%.2f")")
                                .font(.footnote).foregroundStyle(AppColors.textSecondary)
                            Text("Estimated £\(contribution.estimatedAmount, specifier: "%.2f")")
                                .font(.footnote).foregroundStyle(AppColors.success)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(AppColors.card)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(AppColors.background)
            .navigationTitle("History")
        }
    }
}
