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

    private let container: ModelContainer

    init() {
        let schema = Schema([
            Holding.self,
            FinancialProfile.self,
            RebalanceDecision.self,
            Contribution.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create ModelContainer - the app has no data layer and cannot continue: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            AuthGateView()
                .preferredColorScheme((ThemeToggle(rawValue: themeToggleRaw) ?? .dark).colorScheme)

        }.modelContainer(container)
        
    }
}
