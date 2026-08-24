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
    @State private var vm = HoldingsViewModel()

    @State private var name: String = ""
    @State private var symbol: String = ""
    @State private var quantityOrValue: String = ""
    @State private var selectedAssetClass: AssetClass = .equities
    @State private var isMarketTracked: Bool = true
    @State private var isShowingSymbolSearch = false
    @State private var isSaving = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Add a holding").font(.headline).foregroundStyle(AppColors.textPrimary)

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
                    FormField(label: "Holding name", text: $name)
                    FormField(label: "Number of shares/units", text: $quantityOrValue, keyboardType: .decimalPad)
                } else {
                    FormField(label: "Holding name", text: $name)
                    FormField(label: "Current value (£)", text: $quantityOrValue, keyboardType: .decimalPad)
                }

                if let errorMessage = vm.lastErrorMessage {
                    Text(errorMessage).font(.footnote).foregroundStyle(AppColors.warning)
                }

                Button(isSaving ? "Saving..." : "Save holding") {
                    Task { await saveHolding() }
                }
                .disabled(isSaving)
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
            ThemedSheet{
            SymbolSearchView { match in
                symbol = match.symbol
                if name.isEmpty { name = match.description.capitalized }
            }
        }
        }
    }

    private func saveHolding() async {
        guard let enteredNumber = Double(quantityOrValue), !name.isEmpty else {
            vm.lastErrorMessage = "Enter a name and a valid number."
            return
        }

        if isMarketTracked {
            guard !symbol.isEmpty else {
                vm.lastErrorMessage = "A symbol is required for a market-tracked holding."
                return
            }
        }

        isSaving = true
        let saved = await vm.addHolding(
            name: name,
            symbol: isMarketTracked ? symbol : nil,
            quantity: enteredNumber,
            assetClass: selectedAssetClass,
            context: context
        )
        isSaving = false

        if saved { dismiss() }
    }
}
