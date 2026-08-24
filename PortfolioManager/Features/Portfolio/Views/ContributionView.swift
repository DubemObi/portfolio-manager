//
//  ContributeView.swift
//  PortfolioManager
//

import SwiftUI

struct ContributeView: View {
    @Environment(\.dismiss) private var dismiss
    let holding: Holding
    let onComplete: (Double) -> Void

    @State private var quantity: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add to \(holding.name)")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

            FormField(label: "Shares/units to add", text: $quantity, keyboardType: .decimalPad)

            Button {
                guard let value = Double(quantity) else { return }
                onComplete(value)
                dismiss()
            } label: {
                Text("Contribute")
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(AppColors.actionPrimary)
            .foregroundStyle(AppColors.actionPrimaryOn)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding().frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}
