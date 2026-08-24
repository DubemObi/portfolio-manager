//
//  SymbolSearchView.swift
//  PortfolioManager
//

import SwiftUI

struct SymbolSearchView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (FinnhubSymbolMatch) -> Void

    @State private var query: String = ""
    @State private var results: [FinnhubSymbolMatch] = []
    @State private var isSearching = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                FormField(label: "Company or fund name", text: $query)

                Button {
                    Task { await search() }
                } label: {
                    if isSearching { ProgressView() } else { Text("Search") }
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(AppColors.actionPrimary)
                .foregroundStyle(AppColors.actionPrimaryOn)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(query.isEmpty || isSearching)

                if let errorMessage {
                    Text(errorMessage).font(.footnote).foregroundStyle(AppColors.warning)
                }

                List(results) { match in
                    Button {
                        onSelect(match)
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(match.symbol)
                                .font(.subheadline).fontWeight(.semibold)
                                .foregroundStyle(AppColors.textPrimary)
                            Text(match.description)
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    .listRowBackground(AppColors.card)
                }
                .scrollContentBackground(.hidden)
            }
            .padding()
            .background(AppColors.background)
            .navigationTitle("Find a symbol")
        }
    }

    private func search() async {
        isSearching = true
        defer { isSearching = false }

        let result = await PriceService.searchSymbols(query: query)
        switch result {
        case .success(let matches):
            results = matches
            errorMessage = matches.isEmpty ? "No matches found - try a different search term." : nil
        case .failure(.noInternet):
            errorMessage = "You're offline - symbol search needs an internet connection."
        case .failure:
            errorMessage = "Something went wrong - try again."
        }
    }
}
