//
//  ContentView.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 18/07/2026.
//

import SwiftUI
import SwiftData
import Foundation


struct ContentView: View {
    @Query private var holdings: [Holding]
    @Query private var profiles: [FinancialProfile]
    @Query private var decisions: [RebalanceDecision]

        private var pendingCount: Int {
            guard let profile = profiles.first else { return 0 }
            let current = PortfolioHealthEngine.currentAllocation(holdings)
            let candidates = PortfolioHealthEngine.rebalanceCandidates(drift: PortfolioHealthEngine.drift(current: current, target: profile.riskCategory.targetAllocation))
            return AlertsEngine.pendingAlerts(candidates: candidates, decisions: decisions).count
        }
    
    
    var body: some View {
        TabView{
            DashboardView().tabItem {
                Label("Dashboard", systemImage: "gauge.with.dots.needle.67percent")
            }
            PortfolioView().tabItem {
                Label("Portfolio", systemImage: "chart.pie.fill")
            }
            AlertsView().tabItem { Label("Alerts", systemImage: "bell.fill") }
                .badge(pendingCount)
            InsightsView().tabItem { Label("Insights", systemImage: "sparkles") }
//            OnboardingView().tabItem {
//                Label("Onboarding`", systemImage: "chart.pie.fill")
//            }
//            AddHoldingView().tabItem {
//                Label("AddHolding`", systemImage: "chart.bar.fill")
//            }


        }.tint(AppColors.tintOn)
            
        }
    }





#Preview {
    ContentView()
}
