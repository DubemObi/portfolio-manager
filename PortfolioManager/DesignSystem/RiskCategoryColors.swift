//
//  RiskCategoryColors.swift
//  PortfolioManager
//

//  Same pattern as AssetClassColors.swift - kept out of the model itself.
//  Reuses the bonds/real-estate hues for conservative/aggressive (steady
//  vs. bold reads intuitively); moderate gets its own golden-amber,
//  deliberately shifted away from AppColors.warning so a "moderate risk"
//  badge is never visually confused with an actual warning.
//

import SwiftUI

extension FinancialProfile.RiskCategory {
    var color: Color {
        switch self {
        case .conservative: Color.dynamic(light: "0F6E56", dark: "5DCAA5")
        case .moderate: Color.dynamic(light: "C08A17", dark: "F5C15A")
        case .aggressive: Color.dynamic(light: "C1532E", dark: "E2835C")
        }
    }

    var colorBackground: Color {
        switch self {
        case .conservative: Color.dynamic(light: "E1F5EE", dark: "0D2E27")
        case .moderate: Color.dynamic(light: "FBF1DC", dark: "382C0E")
        case .aggressive: Color.dynamic(light: "FBEAE3", dark: "3A2016")
        }
    }

    var icon: String {
        switch self {
        case .conservative: "shield.fill"
        case .moderate: "chart.line.uptrend.xyaxis"
        case .aggressive: "bolt.fill"
        }
    }
}
