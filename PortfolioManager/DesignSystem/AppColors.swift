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
    static let background = Color.dynamic(light: "F9F6EF", dark: "10141C")
    static let card = Color.dynamic(light: "FFFFFF", dark: "161C27")
    static let border = Color.dynamic(light: "E2E4E9", dark: "2A303C")

    static let hero = Color.dynamic(light: "3B2A66", dark: "4A3580")

    static let actionPrimary = Color.dynamic(light: "FACF23", dark: "FACF23")
    static let actionPrimaryText = Color.dynamic(light: "171B24", dark: "171B24")

    static let categoryBackground = Color.dynamic(light: "DFF3EC", dark: "123A30")
    static let categoryText = Color.dynamic(light: "0F6E56", dark: "5DCAA5")

    static let textPrimary = Color.dynamic(light: "171B24", dark: "F2F1ED")
    static let textSecondary = Color.dynamic(light: "6B6F7A", dark: "9AA0AC")
}
