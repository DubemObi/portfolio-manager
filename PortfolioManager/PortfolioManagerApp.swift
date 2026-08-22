//
//  PortfolioManagerApp.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 18/07/2026.
//

import SwiftUI
import SwiftData

@main
struct PortfolioManagerApp: App {
    var body: some Scene {
        WindowGroup {
            AuthGateView()
        }.modelContainer(for: [Holding.self, FinancialProfile.self, RebalanceDecision.self, Contribution.self] )
        
    }
}
