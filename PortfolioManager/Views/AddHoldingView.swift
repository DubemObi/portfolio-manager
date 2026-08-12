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
    @State private var value: String = ""
    @State private var selectedAssetClass: AssetClass = .equities
    @State private var duplicateMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Add a holding")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)

                labeledField("Holding name", text: $name)
                labeledField("Symbol, e.g. AAPL", text: $symbol)
                labeledField("Value", text: $value)

                assetClassPicker
                
                if let duplicateMessage {
                                    Text(duplicateMessage)
                                        .font(.footnote)
                                        .foregroundStyle(.orange)
                                }

                Button("Save holding") {
                    saveHolding()
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(AppColors.actionPrimary)
                .foregroundStyle(AppColors.actionPrimaryText)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .background(AppColors.background)
    }

    private var assetClassPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Asset class")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)

            HStack(spacing: 8) {
                ForEach(AssetClass.allCases) { option in
                    assetClassOption(option)
                }
            }
        }
    }

    private func assetClassOption(_ option: AssetClass) -> some View {
        let isSelected = selectedAssetClass == option

        return Text(option.displayName)
            .font(.footnote)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? AppColors.categoryBackground : AppColors.card)
            .foregroundStyle(isSelected ? AppColors.categoryText : AppColors.textSecondary)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(AppColors.border, lineWidth: 0.5))
            .onTapGesture {
                selectedAssetClass = option
            }
    }

    private func saveHolding() {
        guard
            let valueAmount = Double(value),
            !name.isEmpty,
            !symbol.isEmpty
        else { return }

        let normalizedSymbol = symbol.uppercased()
        let existingHoldings = try? context.fetch(FetchDescriptor<Holding>())

        if existingHoldings?.contains(where: { $0.symbol == normalizedSymbol }) == true {
            duplicateMessage = "You already own \(normalizedSymbol). Update it from your Portfolio instead."
            return
        }

        let holding = Holding(
            name: name,
            value: valueAmount,
            symbol: normalizedSymbol,
            assetClass: selectedAssetClass
        )

        context.insert(holding)
        try? context.save()
        dismiss()
            
    }

    private func labeledField(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)

            TextField("", text: text)
                .padding(10)
                .background(AppColors.card)
                .foregroundStyle(AppColors.textPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.border, lineWidth: 0.5))
        }
    }
}
