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
    @AppStorage("themeToggle") private var themeToggleRaw: String = ThemeToggle.dark.rawValue

    var body: some Scene {
        WindowGroup {
            AuthGateView()
                .preferredColorScheme((ThemeToggle(rawValue: themeToggleRaw) ?? .dark).colorScheme)

        }.modelContainer(for: [Holding.self, FinancialProfile.self, RebalanceDecision.self, Contribution.self] )
        
    }
}
