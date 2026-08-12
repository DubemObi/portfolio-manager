//
//  AffordabilityEngine.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 21/07/2026.
//

struct AffordabilityEngine {
    static func disposableIncome(income: Double, expenses: Double, debtPayments: Double) -> Double {
        return income - expenses - debtPayments
    }
}
