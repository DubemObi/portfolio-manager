//
//  PriceViewModel.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 27/07/2026.
//

import SwiftData

@Observable
class PriceViewModel {
    var isLoading = false
    var priceText = "No price fetched yet"
    
    func loadPrice(symbol: String) async {
        isLoading = true
        defer { isLoading = false }

        let result = await PriceService.fetchQuote(symbol: symbol)
        switch result {
        case .success(let quote):
            priceText = "Current price: £\(quote.c)"
        case .failure(.noInternet):
            priceText = "You appear to be offline."
        case .failure(.badResponse(let statusCode)):
            priceText = "Server responded with status \(statusCode)."
        case .failure(.decodingFailed):
            priceText = "Got a response, but couldn't understand it."
        }
    }
}
