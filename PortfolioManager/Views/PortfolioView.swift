//
//  PortfolioView.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 27/07/2026.
//
import SwiftUI
import SwiftData

struct PortfolioView: View {
    @Environment(\.modelContext) private var context
    @Query private var holdings: [Holding]
    @Query private var profiles: [FinancialProfile]
    
    @State private var vm = PortfolioViewModel()
    @State private var isShowingAddHolding: Bool = false
    
    var body: some View {
        NavigationStack{
            
            List(holdings){holding in
                VStack(alignment: .leading, spacing: 4) {
                        Text("\(holding.name): £\(holding.value, specifier: "%.2f") (\(holding.symbol))")

                        if let lastUpdated = holding.lastUpdated {
                            Text("Updated \(lastUpdated.formatted(.relative(presentation: .named)))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Never refreshed")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        if let error = vm.lastErrorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    
                    Button ("Refresh Price"){
                        Task{
                            await vm.refreshPrice(for: holding, context: context)
                        }
                    }
                }
            }.navigationTitle("Portfolio")
                .toolbar {
                    Button{
                        isShowingAddHolding = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }.sheet(isPresented: $isShowingAddHolding){
                    AddHoldingView()
                }.task {
                    let drift = PortfolioHealthEngine.drift(current: PortfolioHealthEngine.currentAllocation(holdings), target: RiskCategory.moderate.targetAllocation)
                    
                    
                    if let profile = profiles.first {
                        print("\(drift)\n\nPortfolio Rebalance\n\(PortfolioHealthEngine.rebalanceCandidates(drift: drift))\n\n\(PortfolioHealthEngine.healthScore(holdings: holdings, profile: profile))")
                    }
                }
        }

    }
}
