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
    @AppStorage("themeToggle") private var themeToggleRaw: String = ThemeToggle.system.rawValue

    var body: some Scene {
        WindowGroup {
            AuthGateView()
                .preferredColorScheme(ThemeToggle(rawValue: themeToggleRaw)?.colorScheme)

        }.modelContainer(for: [Holding.self, FinancialProfile.self, RebalanceDecision.self, Contribution.self] )
        
    }
}
