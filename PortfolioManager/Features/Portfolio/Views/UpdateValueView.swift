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
    @State private var vm = HoldingsViewModel()

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

                if let errorMessage = vm.lastErrorMessage {
                    Text(errorMessage).font(.footnote).foregroundStyle(AppColors.warning)
                }

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
        guard let value = Double(newValue) else {
            vm.lastErrorMessage = "Enter a valid number."
            return
        }
        let saved = vm.updateValue(for: holding, newValue: value, context: context)
        if saved { dismiss() }
    }
}
