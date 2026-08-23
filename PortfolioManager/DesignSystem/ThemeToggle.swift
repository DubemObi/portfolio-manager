//
//  ThemeToggle.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 22/08/2026.
//


import SwiftUI

enum ThemeToggle: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    /// nil means "follow the system setting" - SwiftUI's own convention
    /// for .preferredColorScheme.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
