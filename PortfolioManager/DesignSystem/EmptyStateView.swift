//
//  EmptyStateView.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 14/08/2026.
//
import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let message: String
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.largeTitle).foregroundStyle(AppColors.textSecondary)
            Text(message).font(.subheadline).foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
}
