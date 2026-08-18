//
//  PortfolioViewModel.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 27/07/2026.
//
import SwiftData
import Foundation

@Observable
class PortfolioViewModel{
    var lastErrorMessage: String?
    
    func refreshPrice(for holding: Holding, context: ModelContext) async{
        guard let symbol = holding.symbol else {return}
        let result = await PriceService.fetchQuote(symbol:  symbol)
        
        switch result {
        case .success(let quote):
            holding.pricePerUnit = quote.c
            holding.lastUpdated = .now
            lastErrorMessage = nil
            
            try? context.save()
            
        case .failure(.noInternet):
            lastErrorMessage = "You're offline - showing last know price."
        case .failure(.badResponse), .failure(.decodingFailed):
                lastErrorMessage = "Couldn't refresh price - showing last known price."
        }
    }
}
