//
//  FinnhubSymbolSearch.swift
//  PortfolioManager
//

import Foundation

struct FinnhubSymbolMatch: Codable, Identifiable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String

    var id: String { symbol }
}

struct FinnhubSymbolSearchResponse: Codable {
    let count: Int
    let result: [FinnhubSymbolMatch]
}
