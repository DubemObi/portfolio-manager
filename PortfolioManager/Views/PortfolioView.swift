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
    @State private var isRefreshingAll = false

    var body: some View {
        NavigationStack {
            Group {
                if holdings.isEmpty {
                    EmptyStateView(icon: "chart.pie", message: "No holdings yet - tap + to add one.")
                } else {
                    List {
                        if let lastErrorMessage = vm.lastErrorMessage {
                            Text(lastErrorMessage)
                                .font(.footnote)
                                .foregroundStyle(AppColors.warning)
                                .listRowBackground(AppColors.warningBackground)
                        }

                        ForEach(holdings) { holding in
                            HoldingRowView(
                                holding: holding,
                                onRefresh: { Task { await vm.refreshPrice(for: holding, context: context) } },
                                onEdit: { holdingToUpdate = holding },
                                onContribute: { holdingToContribute = holding }
                            )
                            .listRowBackground(AppColors.card)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(AppColors.background)
            .navigationTitle("Portfolio")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        Task {
                            isRefreshingAll = true
                            await vm.refreshAllPrices(holdings: holdings, context: context)
                            isRefreshingAll = false
                        }
                    } label: {
                        if isRefreshingAll {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                    }
                    .disabled(isRefreshingAll)

                    Button { isShowingAddHolding = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $isShowingAddHolding) { AddHoldingView() }
            .sheet(item: $holdingToUpdate) { holding in UpdateValueView(holding: holding) }
            .sheet(item: $holdingToContribute) { holding in
                ContributeView(holding: holding) { quantity in
                    vm.contribute(to: holding, quantityToAdd: quantity, context: context)
                    if holding.symbol != nil {
                        Task { await vm.refreshPrice(for: holding, context: context) }
                    }
                }
            }
        }
    }
}
