//
//  HoldingRowView.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 18/08/2026.
//

import SwiftUI

struct HoldingRowView: View {
    let holding: Holding
    let onRefresh: () -> Void
    let onEdit: () -> Void
    let onContribute: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: holding.assetClass.icon)
                .frame(width: 36, height: 36)
                .background(AppColors.tint)
                .foregroundStyle(AppColors.tintOn)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(holding.name).foregroundStyle(AppColors.textPrimary)
                Text(holding.lastUpdated?.formatted(.relative(presentation: .named)) ?? "Never updated")
                    .font(.caption2)
                    .foregroundStyle(holding.isStale ? AppColors.warning : AppColors.textSecondary)
            }

            Spacer()
            Text("£\(holding.value, specifier: "%.2f")").foregroundStyle(AppColors.textPrimary)

            if holding.symbol != nil {
                Button(action: onContribute) { Image(systemName: "plus.circle").foregroundStyle(AppColors.action) }.buttonStyle(.borderless)
                Button(action: onRefresh) {
                    Image(systemName: "arrow.clockwise").foregroundStyle(AppColors.action)
                }.buttonStyle(.borderless)
            } else {
                Button(action: onContribute) { Image(systemName: "plus.circle").foregroundStyle(AppColors.action) }.buttonStyle(.borderless)
                Button(action: onEdit) {
                    Image(systemName: "pencil").foregroundStyle(AppColors.action)
                }.buttonStyle(.borderless)
            }
        }
    }
}
