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
    var body: some View {
        TabView{
            DashboardView().tabItem {
                Label("Dashboard", systemImage: "gauge.with.dots.needle.67percent")
            }
            PortfolioView().tabItem {
                Label("Portfolio", systemImage: "chart.pie.fill")
            }
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
