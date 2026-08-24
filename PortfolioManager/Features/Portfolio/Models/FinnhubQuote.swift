//
//  FinnhubQuote.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 26/07/2026.
//

struct FinnhubQuote: Codable {
    let c: Double   // current price
    let h: Double   // high
    let l: Double   // low
    let o: Double   // open
    let pc: Double  // previous close
}
