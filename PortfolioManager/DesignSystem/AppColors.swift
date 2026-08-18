//
//  AppColors.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 06/08/2026.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let red = Double((rgbValue >> 16) & 0xFF) / 255
        let green = Double((rgbValue >> 8) & 0xFF) / 255
        let blue = Double(rgbValue & 0xFF) / 255

        self.init(red: red, green: green, blue: blue)
    }

    static func dynamic(light: String, dark: String) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(Color(hex: dark)) : UIColor(Color(hex: light))
        })
    }
}


enum AppColors {
    // Surfaces
    static let background = Color.dynamic(light: "F7F7F5", dark: "14171C")
    static let card = Color.dynamic(light: "FFFFFF", dark: "1E222A")
    static let border = Color.dynamic(light: "E5E5E2", dark: "2C313A")

    // Text
    static let textPrimary = Color.dynamic(light: "14171C", dark: "F2F1ED")
    static let textSecondary = Color.dynamic(light: "6B7280", dark: "9AA0AC")

    // Purple - material only, never interactive
    static let brand = Color.dynamic(light: "3B2A66", dark: "5A4A96")
    static let brandOn = Color.white

    /// The single most important action per screen ONLY - Continue,
    /// Save, Generate Insights, Accept. Deliberately a vivid, highly
    /// saturated yellow (not a muted amber) so it never gets confused
    /// with `warning` below, despite both living in the yellow family.
    static let actionPrimary = Color.dynamic(light: "FFC400", dark: "FFD400")
    static let actionPrimaryOn = Color(hex: "14171C")   // near-black text, fixed - stays readable on yellow in both themes

    /// Every other button - Snooze, Decline, Cancel, icon actions.
    /// Neutral, inverts between themes.
    static let action = Color.dynamic(light: "14171C", dark: "F2F1ED")
    static let actionOn = Color.dynamic(light: "FFFFFF", dark: "14171C")

    // Status - deliberately desaturated/muted so it reads as
    // "caution," clearly distinct from actionPrimary's vividness
    static let success = Color.dynamic(light: "1E8E5A", dark: "4ADE94")
    static let successBackground = Color.dynamic(light: "E7F5EE", dark: "173327")
    static let warning = Color.dynamic(light: "B7791F", dark: "F0B429")
    static let warningBackground = Color.dynamic(light: "FBF0DE", dark: "332707")

    // Category - muted, unrelated to any of the above
    static let tint = Color.dynamic(light: "EEF0F3", dark: "262B33")
    static let tintOn = Color.dynamic(light: "4B5563", dark: "B8C0CC")
}

