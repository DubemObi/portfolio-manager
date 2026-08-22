//
//  FinancialGoal.swift
//  PortfolioManager
//

import Foundation

enum FinancialGoal: String, CaseIterable, Codable, Identifiable {
    case retirement, buyingHome, longTermWealth, education, financialSecurity, majorPurchase, startingBusiness, somethingElse

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .retirement: "🏖️"
        case .buyingHome: "🏠"
        case .longTermWealth: "📈"
        case .education: "🎓"
        case .financialSecurity: "🛟"
        case .majorPurchase: "✈️"
        case .startingBusiness: "💼"
        case .somethingElse: "🎯"
        }
    }

    var displayName: String {
        switch self {
        case .retirement: "Retirement"
        case .buyingHome: "Buying a home"
        case .longTermWealth: "Build long-term wealth"
        case .education: "Education"
        case .financialSecurity: "Financial security"
        case .majorPurchase: "Major purchase"
        case .startingBusiness: "Start a business"
        case .somethingElse: "Something else"
        }
    }
}
