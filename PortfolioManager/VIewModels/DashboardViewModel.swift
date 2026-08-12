//
//  DashViewModel.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 21/07/2026.
//
import SwiftUI
import SwiftData


@Observable
class DashboardViewModel{
    var profile: FinancialProfile?
    var disposableIncome: Double = 0
    var totalPortfolioValue: Double = 0
    var healthScore = HealthScore(overall: 0, assetClassCoverage: 0, riskAlignment: 0)
    
    func load(context: ModelContext){
        let descriptor = FetchDescriptor<FinancialProfile>()

        guard let fetchedProfile = try? context.fetch(descriptor).first else { return }
        
        profile = fetchedProfile

        disposableIncome = AffordabilityEngine.disposableIncome(
                    income: fetchedProfile.monthlyIncome,
                    expenses: fetchedProfile.monthlyExpenses,
                    debtPayments: fetchedProfile.monthlyDebtPayments
        )
        
        let holdingDescriptor = FetchDescriptor<Holding>()
        guard let holdings = try? context.fetch(holdingDescriptor) else { return }

        totalPortfolioValue = PortfolioHealthEngine.totalValue(holdings)
        healthScore = PortfolioHealthEngine.healthScore(holdings: holdings, profile: fetchedProfile)
    }
}
