//
//  ContentView.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 18/07/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var holdings: [Holding]
    @Query private var profiles: [FinancialProfile]
    @Query private var decisions: [RebalanceDecision]

    private var pendingCount: Int {
        guard let profile = profiles.first, !holdings.isEmpty else { return 0 }
        let current = PortfolioHealthEngine.currentAllocation(holdings)
        let drift = PortfolioHealthEngine.drift(current: current, target: profile.riskCategory.targetAllocation)
        let candidates = PortfolioHealthEngine.rebalanceCandidates(drift: drift)
        return AlertsEngine.pendingAlerts(candidates: candidates, decisions: decisions).count
    }

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "gauge.with.dots.needle.67percent") }

            PortfolioView()
                .tabItem { Label("Portfolio", systemImage: "chart.pie.fill") }

            AlertsView()
                .tabItem { Label("Alerts", systemImage: "bell.fill") }
                .badge(pendingCount)

            InsightsView()
                .tabItem { Label("Insights", systemImage: "sparkles") }
        }
        .tint(AppColors.action)
    }
}



#Preview {
    ContentView()
}
