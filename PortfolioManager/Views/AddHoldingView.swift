//
//  AddHoldingView.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 10/08/2026.
//

import SwiftUI
import SwiftData

struct AddHoldingView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var symbol: String = ""
    @State private var quantityOrValue: String = ""
    @State private var selectedAssetClass: AssetClass = .equities
    @State private var isMarketTracked: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Add a holding").font(.headline).foregroundStyle(AppColors.textPrimary)

                FormField(label: "Holding name", text: $name)

                ChipPicker(
                    title: "Asset class",
                    options: AssetClass.allCases,
                    displayName: { $0.displayName },
                    selection: $selectedAssetClass
                )
                .onChange(of: selectedAssetClass) { _, newValue in
                    // Equities are always market-tracked, cash never is;
                    // everything else defaults to tracked but stays user-editable.
                    if newValue == .cash { isMarketTracked = false }
                    if newValue == .equities { isMarketTracked = true }
                }

                if selectedAssetClass != .cash && selectedAssetClass != .equities {
                    Toggle("This holding has a ticker symbol I can track", isOn: $isMarketTracked)
                        .tint(AppColors.action)
                }

                if isMarketTracked {
                    FormField(label: "Symbol, e.g. AAPL", text: $symbol)
                    FormField(label: "Number of shares/units", text: $quantityOrValue, keyboardType: .decimalPad)
                } else {
                    FormField(label: "Current value (£)", text: $quantityOrValue, keyboardType: .decimalPad)
                }

                if let errorMessage {
                    Text(errorMessage).font(.footnote).foregroundStyle(.orange)
                }

                Button("Save holding") { saveHolding() }
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

    private func saveHolding() {
        guard let enteredNumber = Double(quantityOrValue), !name.isEmpty else { return }

        if isMarketTracked {
            guard !symbol.isEmpty else {
                errorMessage = "A symbol is required for a market-tracked holding."
                return
            }
            let normalizedSymbol = symbol.uppercased()
            let existing = try? context.fetch(FetchDescriptor<Holding>())
            if existing?.contains(where: { $0.symbol == normalizedSymbol }) == true {
                errorMessage = "You already own \(normalizedSymbol). Update it from your Portfolio instead."
                return
            }

            let holding = Holding(
                name: name,
                symbol: normalizedSymbol,
                quantity: enteredNumber,
                pricePerUnit: 0,   // unresolved until first "Refresh Price"
                lastUpdated: nil,
                assetClass: selectedAssetClass
            )
            context.insert(holding)
        } else {
            let holding = Holding(
                name: name,
                symbol: nil,
                quantity: enteredNumber,   // the £ value itself, since pricePerUnit stays 1
                pricePerUnit: 1,
                lastUpdated: .now,
                assetClass: selectedAssetClass
            )
            context.insert(holding)
        }

        try? context.save()
        dismiss()
    }
}
