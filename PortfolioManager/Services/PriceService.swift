//
//  PriceService.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 27/07/2026.
//
import Foundation

enum PriceFetchError: Error {
    case noInternet
    case badResponse(statusCode: Int)
    case decodingFailed
}

struct PriceService {
    
    static func fetchQuote(symbol: String) async -> Result<FinnhubQuote, PriceFetchError> {
        let urlString = "https://finnhub.io/api/v1/quote?symbol=\(symbol)&token=\(Secrets.finnhubAPIKey)"
        
        guard let url = URL(string: urlString) else {
            return .failure(.badResponse(statusCode: -1))
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                return .failure(.badResponse(statusCode: statusCode))
            }
            
            guard let quote = try? JSONDecoder().decode(FinnhubQuote.self, from: data) else {
                return .failure(.decodingFailed)
            }
            
            return .success(quote)
            
        } catch let error as URLError where error.code == .notConnectedToInternet {
            return .failure(.noInternet)
        } catch {
            return .failure(.badResponse(statusCode: -1))
        }
    }
}
