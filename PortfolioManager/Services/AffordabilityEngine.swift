//
//  AffordabilityEngine.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 21/07/2026.
//

import Foundation

struct AffordabilityEngine {

    static func disposableIncome(income: Double, expenses: Double, debtPayments: Double) -> Double {
        max(0, income - expenses - debtPayments)
    }

    /// How many months of expenses the user's current savings would cover.
    static func emergencyFundCoverageMonths(_ profile: FinancialProfile) -> Double {
        guard profile.monthlyExpenses > 0 else { return 0 }
        return profile.currentSavings / profile.monthlyExpenses
    }

    /// Safe monthly investment capacity: withholds disposable income until a
    /// 3-month emergency fund is covered, then treats the full disposable
    /// income as investable. 3 months is a fixed, stated assumption here
    /// (not a user-configurable field) - worth flagging as a simplification
    /// in the write-up, same as the projection engine's return-rate assumption.
    static func safeMonthlyInvestment(_ profile: FinancialProfile) -> Double {
        let coverage = emergencyFundCoverageMonths(profile)
        let disposable = disposableIncome(
            income: profile.monthlyIncome,
            expenses: profile.monthlyExpenses,
            debtPayments: profile.monthlyDebtPayments
        )
        guard coverage >= 3 else { return 0 }
        return disposable
    }
}
