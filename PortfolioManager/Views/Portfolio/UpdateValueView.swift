//
//  UpdateValueView.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 15/08/2026.
//

import SwiftUI
import SwiftData

struct UpdateValueView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let holding: Holding
    @State private var newValue: String

    init(holding: Holding) {
        self.holding = holding
        _newValue = State(initialValue: String(format: "%.2f", holding.value))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Update \(holding.name)")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)

                Text("This holding has no live market price - update its value manually whenever it changes (e.g. a new property valuation, or a change in your cash balance).")
                    .font(.footnote)
                    .foregroundStyle(AppColors.textSecondary)

                FormField(label: "Current value (£)", text: $newValue, keyboardType: .decimalPad)

                Button("Save") { saveValue() }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(AppColors.actionPrimary)
                    .foregroundStyle(AppColors.actionPrimaryOn)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .background(AppColors.background)
    }

    private func saveValue() {
        guard let value = Double(newValue) else { return }

        // pricePerUnit stays fixed at 1 for manually-valued holdings,
        // so quantity is the pound value directly - same convention
        // used when this holding was first created.
        holding.quantity = value
        holding.lastUpdated = .now
        try? context.save()
        dismiss()
    }
}
