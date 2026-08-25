//
//  PriceService.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 27/07/2026.

import Foundation

enum PriceFetchError: Error {
    case noInternet
    case badResponse(statusCode: Int)
    case decodingFailed
}

struct PriceService {

    static func fetchQuote(symbol: String) async -> Result<FinnhubQuote, PriceFetchError> {
        guard let encodedSymbol = symbol.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return .failure(.badResponse(statusCode: -1))
        }
        let urlString = "https://finnhub.io/api/v1/quote?symbol=\(encodedSymbol)&token=\(Secrets.finnhubAPIKey)"

        guard let url = URL(string: urlString) else {
            return .failure(.badResponse(statusCode: -1))
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                return .failure(.badResponse(statusCode: statusCode))
            }

            do {
                let quote = try JSONDecoder().decode(FinnhubQuote.self, from: data)
                return .success(quote)
            } catch {
                print("PriceService: quote decode failed for \(symbol) - \(error)")
                return .failure(.decodingFailed)
            }

        } catch let error as URLError where error.code == .notConnectedToInternet {
            return .failure(.noInternet)
        } catch {
            print("PriceService: quote fetch failed for \(symbol) - \(error)")
            return .failure(.badResponse(statusCode: -1))
        }
    }

    static func searchSymbols(query: String) async -> Result<[FinnhubSymbolMatch], PriceFetchError> {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return .failure(.badResponse(statusCode: -1))
        }
        let urlString = "https://finnhub.io/api/v1/search?q=\(encodedQuery)&token=\(Secrets.finnhubAPIKey)"

        guard let url = URL(string: urlString) else {
            return .failure(.badResponse(statusCode: -1))
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                return .failure(.badResponse(statusCode: statusCode))
            }

            do {
                let decoded = try JSONDecoder().decode(FinnhubSymbolSearchResponse.self, from: data)
                return .success(decoded.result)
            } catch {
                print("PriceService: search decode failed for '\(query)' - \(error)")
                return .failure(.decodingFailed)
            }

        } catch let error as URLError where error.code == .notConnectedToInternet {
            return .failure(.noInternet)
        } catch {
            print("PriceService: search fetch failed for '\(query)' - \(error)")
            return .failure(.badResponse(statusCode: -1))
        }
    }
}
