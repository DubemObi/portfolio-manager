//
//  RootFlowView.swift
//  PortfolioManager
//

import SwiftUI
import SwiftData

struct RootFlowView: View {
    @Query private var profiles: [FinancialProfile]

    var body: some View {
        if profiles.isEmpty {
            OnboardingView()
        } else {
            ContentView()
        }
    }
}
