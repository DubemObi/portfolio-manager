//
//  StepProgressHeader.swift
//  PortfolioManager
//

import SwiftUI

struct StepProgressHeader: View {
    let title: String
    let currentStep: Int // 0-indexed
    let totalSteps: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
                Text("Step \(currentStep + 1) of \(totalSteps)")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            HStack(spacing: 4) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index <= currentStep ? AppColors.brand : AppColors.tint)
                        .frame(height: 4)
                }
            }
        }
    }
}
