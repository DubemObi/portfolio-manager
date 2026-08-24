//
//  AssetClassColors.swift
//  PortfolioManager
//

//  Kept separate from Holdings.swift deliberately - AssetClass itself
//  stays a plain Foundation enum with no SwiftUI dependency; this file
//  is where the data model's categories get mapped to actual colour,
//  same separation as everywhere else UI concerns are kept out of Models.
//

import SwiftUI

extension AssetClass {
    /// Solid, saturated - used for donut segments, icon backgrounds,
    /// legend swatches, and target-comparison bars.
    var color: Color {
        switch self {
        case .equities: Color.dynamic(light: "2E7FD1", dark: "6DAEEA")
        case .bonds: Color.dynamic(light: "0F6E56", dark: "5DCAA5")
        case .cash: Color.dynamic(light: "52606D", dark: "9AA6B2")
        case .realEstate: Color.dynamic(light: "C1532E", dark: "E2835C")
        case .commodities: Color.dynamic(light: "B23A6B", dark: "E28AB0")
        }
    }

    /// Pale tint of the same hue - for chip/badge backgrounds where the
    /// solid colour would be too heavy.
    var colorBackground: Color {
        switch self {
        case .equities: Color.dynamic(light: "E6F1FB", dark: "123152")
        case .bonds: Color.dynamic(light: "E1F5EE", dark: "0D2E27")
        case .cash: Color.dynamic(light: "EEF0F3", dark: "262B33")
        case .realEstate: Color.dynamic(light: "FBEAE3", dark: "3A2016")
        case .commodities: Color.dynamic(light: "FBEAF0", dark: "34141F")
        }
    }
}
