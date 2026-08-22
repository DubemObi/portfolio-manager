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
    @State private var isShowingSymbolSearch = false

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
                    if newValue == .cash { isMarketTracked = false }
                    if newValue == .equities { isMarketTracked = true }
                }

                if selectedAssetClass != .cash && selectedAssetClass != .equities {
                    Toggle("This holding has a ticker symbol I can track", isOn: $isMarketTracked)
                        .tint(AppColors.actionPrimary)
                }

                if isMarketTracked {
                    HStack {
                        FormField(label: "Symbol, e.g. AAPL", text: $symbol)
                        Button {
                            isShowingSymbolSearch = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }
                        .padding(.top, 20)
                        .foregroundStyle(AppColors.action)
                    }
                    FormField(label: "Number of shares/units", text: $quantityOrValue, keyboardType: .decimalPad)
                } else {
                    FormField(label: "Current value (£)", text: $quantityOrValue, keyboardType: .decimalPad)
                }

                if let errorMessage {
                    Text(errorMessage).font(.footnote).foregroundStyle(AppColors.warning)
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
        .sheet(isPresented: $isShowingSymbolSearch) {
            SymbolSearchView { match in
                symbol = match.symbol
                if name.isEmpty { name = match.description.capitalized }
            }
        }
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

            Task {
                let result = await PriceService.fetchQuote(symbol: normalizedSymbol)
                let (price, lastUpdated): (Double, Date?) = {
                    if case .success(let quote) = result { return (quote.c, .now) }
                    return (0, nil)
                }()

                let holding = Holding(
                    name: name, symbol: normalizedSymbol, quantity: enteredNumber,
                    pricePerUnit: price, lastUpdated: lastUpdated, assetClass: selectedAssetClass
                )
                context.insert(holding)
                try? context.save()
                dismiss()
            }
        } else {
            let holding = Holding(
                name: name, symbol: nil, quantity: enteredNumber,
                pricePerUnit: 1, lastUpdated: .now, assetClass: selectedAssetClass
            )
            context.insert(holding)
            try? context.save()
            dismiss()
        }
    }
}
