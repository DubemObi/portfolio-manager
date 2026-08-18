//
//  FormField.swift
//  PortfolioManager
//

import SwiftUI

struct FormField: View {
    let label: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundStyle(AppColors.textSecondary)
            TextField("", text: $text)
                .keyboardType(keyboardType)
                .padding(10)
                .background(AppColors.card)
                .foregroundStyle(AppColors.textPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.border, lineWidth: 0.5))
        }
    }
}
