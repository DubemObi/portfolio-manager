//
//  PortfolioView.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 27/07/2026.
//
import SwiftUI
import SwiftData

//struct PortfolioView: View {
//    @Environment(\.modelContext) private var context
//    @Query private var holdings: [Holding]
//    @Query private var profiles: [FinancialProfile]
//    
//    @State private var vm = PortfolioViewModel()
//    @State private var isShowingAddHolding: Bool = false
//    
//    var body: some View {
//        NavigationStack{
//            
//            List(holdings) { holding in
//                HStack(spacing: 12) {
//                    Image(systemName: holding.assetClass.icon)
//                        .frame(width: 36, height: 36)
//                        .background(AppColors.tint)
//                        .foregroundStyle(AppColors.tintOn)
//                        .clipShape(Circle())
//
//                    VStack(alignment: .leading, spacing: 2) {
//                        Text(holding.name).foregroundStyle(AppColors.textPrimary)
//                        Text(holding.lastUpdated?.formatted(.relative(presentation: .named)) ?? "Never refreshed")
//                            .font(.caption2).foregroundStyle(AppColors.textSecondary)
//                    }
//
//                    Spacer()
//                    Text("£\(holding.value, specifier: "%.2f")").foregroundStyle(AppColors.textPrimary)
//
//                    Button {
//                        Task { await vm.refreshPrice(for: holding, context: context) }
//                    } label: {
//                        Image(systemName: holding.symbol != nil ? "arrow.clockwise" : "pencil")
//                            .foregroundStyle(AppColors.action)
//                    }
//                }
//                .listRowBackground(AppColors.card)
//            }
//            .scrollContentBackground(.hidden)
//            .background(AppColors.background).navigationTitle("Portfolio")
//                .toolbar {
//                    Button{
//                        isShowingAddHolding = true
//                    } label: {
//                        Image(systemName: "plus")
//                    }
//                }.sheet(isPresented: $isShowingAddHolding){
//                    AddHoldingView()
//                }.task {
//                    let drift = PortfolioHealthEngine.drift(current: PortfolioHealthEngine.currentAllocation(holdings), target: RiskCategory.moderate.targetAllocation)
//                    
//                    
//                    if let profile = profiles.first {
//                        print("\(drift)\n\nPortfolio Rebalance\n\(PortfolioHealthEngine.rebalanceCandidates(drift: drift))\n\n\(PortfolioHealthEngine.healthScore(holdings: holdings, profile: profile))")
//                    }
//                }
//        }
//
//    }
//}


struct PortfolioView: View {
    @Environment(\.modelContext) private var context
    @Query private var holdings: [Holding]
    @Query private var profiles: [FinancialProfile]

    @State private var vm = PortfolioViewModel()
    @State private var isShowingAddHolding = false
    @State private var holdingToUpdate: Holding?

    var body: some View {
        NavigationStack {
            Group {
                if holdings.isEmpty {
                    ContentUnavailableView(
                        "No Holdings",
                        systemImage: "chart.pie",
                        description: Text("Add your first holding to start building your portfolio.")
                    )
                } else {
                    List(holdings) { holding in
                        HStack(spacing: 12) {
                            Image(systemName: holding.assetClass.icon)
                                .frame(width: 36, height: 36)
                                .background(AppColors.tint)
                                .foregroundStyle(AppColors.tintOn)
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(holding.name)
                                    .foregroundStyle(AppColors.textPrimary)

                                Text(
                                    holding.lastUpdated?
                                        .formatted(.relative(presentation: .named))
                                    ?? "Never refreshed"
                                )
                                .font(.caption2)
                                .foregroundStyle(AppColors.textSecondary)
                            }

                            Spacer()

                            Text("£\(holding.value, specifier: "%.2f")")
                                .foregroundStyle(AppColors.textPrimary)

                            if holding.symbol != nil{
                                Button {
                                    Task {
                                        await vm.refreshPrice(
                                            for: holding,
                                            context: context
                                        )
                                    }
                                } label: {
                                    Image(
                                        systemName: holding.symbol != nil
                                        ? "arrow.clockwise"
                                        : "pencil"
                                    )
                                    .foregroundStyle(AppColors.action)
                                }
                            }else {
                                Button {
                                    holdingToUpdate = holding
                                } label: {
                                    Image(systemName: "pencil").foregroundStyle(AppColors.action)
                                }
                            }
                        }
                        .listRowBackground(AppColors.card)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(AppColors.background)
            .navigationTitle("Portfolio")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddHolding = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddHolding) {
                AddHoldingView()
            }
            .sheet(item: $holdingToUpdate) { holding in UpdateValueView(holding: holding) }

        }
    }
}
