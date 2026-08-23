//
//  ThemeToggle.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 22/08/2026.
//

import SwiftUI

enum ThemeToggle: String, CaseIterable, Identifiable {
    case light, dark

    var id: String { rawValue }

    var colorScheme: ColorScheme {
        switch self {
        case .light: .light
        case .dark: .dark
        }
    }

    /// Sun for light, half-moon for dark - the icon always shows the
    /// current state, and tapping it switches to the other one.
    var icon: String {
        switch self {
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        }
    }

    var opposite: ThemeToggle {
        self == .light ? .dark : .light
    }
}
