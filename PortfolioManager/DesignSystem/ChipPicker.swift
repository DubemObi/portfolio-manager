//
//  ChipPicker.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 13/08/2026.
//

import SwiftUI

struct ChipPicker<Option: Hashable & Identifiable>: View {
    let title: String
    let options: [Option]
    let displayName: (Option) -> String
    @Binding var selection: Option

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).foregroundStyle(AppColors.textSecondary)
            HStack(spacing: 8) {
                ForEach(options) { option in
                    let isSelected = option == selection
                    Text(displayName(option))
                        .font(.footnote.weight(isSelected ? .semibold : .regular))
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(isSelected ? AppColors.action : AppColors.card)
                        .foregroundStyle(isSelected ? AppColors.actionOn : AppColors.textSecondary)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(AppColors.border, lineWidth: 0.5))
                        .onTapGesture { selection = option }
                }
            }
        }
    }
}
