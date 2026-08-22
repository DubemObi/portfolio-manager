//
//  PortfolioView.swift
//  PortfolioManager
//

import SwiftUI
import SwiftData

struct PortfolioView: View {
    @Environment(\.modelContext) private var context
    @Query private var holdings: [Holding]
    @State private var vm = PortfolioViewModel()
    @State private var isShowingAddHolding = false
    @State private var holdingToUpdate: Holding?
    @State private var holdingToContribute: Holding?

    var body: some View {
        NavigationStack {
            Group {
                if holdings.isEmpty {
                    EmptyStateView(icon: "chart.pie", message: "No holdings yet - tap + to add one.")
                } else {
                    List(holdings) { holding in
                        HoldingRowView(
                            holding: holding,
                            onRefresh: { Task { await vm.refreshPrice(for: holding, context: context) } },
                            onEdit: { holdingToUpdate = holding },
                            onContribute: { holdingToContribute = holding }
                        )
                        .listRowBackground(AppColors.card)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(AppColors.background)
            .navigationTitle("Portfolio")
            .toolbar {
                Button { isShowingAddHolding = true } label: { Image(systemName: "plus") }
            }
            .sheet(isPresented: $isShowingAddHolding) { AddHoldingView() }
            .sheet(item: $holdingToUpdate) { holding in UpdateValueView(holding: holding) }
            .sheet(item: $holdingToContribute) { holding in
                ContributeView(holding: holding) { quantity in
                    vm.contribute(to: holding, quantityToAdd: quantity, context: context)

                    // Best-effort only: contribute() already succeeded and
                    // saved above, regardless of what happens here. This is
                    // purely an attempt to freshen the price afterward.
                    if holding.symbol != nil {
                        Task { await vm.refreshPrice(for: holding, context: context) }
                    }
                }
            }
        }
    }
}
