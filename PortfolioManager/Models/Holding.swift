//
//  Holdings.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 19/07/2026.
//
import SwiftData
import Foundation

enum AssetClass: String, CaseIterable, Codable, Identifiable {
    case equities, bonds, cash, realEstate, commodities

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .equities:
            "Equities"
        case .bonds:
            "Bonds"
        case .cash:
            "Cash"
        case .realEstate:
            "Real Estate"
        case .commodities:
            "Commodities"
        }
    }
}


@Model
class Holding {
    var name: String
    var value: Double
    var symbol: String
    var lastUpdated: Date?
    var assetClass: AssetClass = AssetClass.equities
    
    init(name: String, value: Double, symbol: String, lastUpdated: Date? = nil, assetClass: AssetClass = .equities){
        self.name = name
        self.value = value
        self.symbol = symbol
        self.lastUpdated = lastUpdated
        self.assetClass = assetClass
    }
}

