//
//  GoalCardPicker.swift
//  PortfolioManager
//

import SwiftUI

struct GoalCardPicker: View {
    @Binding var selection: FinancialGoal

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(FinancialGoal.allCases) { goal in
                let isSelected = goal == selection

                HStack(spacing: 6) {
                    Text(goal.emoji)
                    Text(goal.displayName)
                        .font(.footnote)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                    Spacer(minLength: 0)
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppColors.actionOn)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
                .background(isSelected ? AppColors.action : AppColors.card)
                .foregroundStyle(isSelected ? AppColors.actionOn : AppColors.textPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColors.border, lineWidth: 0.5))
                .onTapGesture { selection = goal }
            }
        }
    }
}
