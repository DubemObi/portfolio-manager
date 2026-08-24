//
//  PortfolioHealthEngine.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 21/07/2026.
//

struct HealthScore {
    var overall: Double
    var assetClassCoverage: Double
    var riskAlignment: Double
    
    /// User-facing alias internally this measures breadth of asset classes
    /// held, not evenness of allocation, hence the more precise property name.
    var diversification: Double { assetClassCoverage }
}

struct PortfolioHealthEngine {
    static func totalValue(_ holdings: [Holding]) -> Double {
        holdings.reduce(0) { runningTotal, holding in runningTotal + holding.value }
    }
    
    static func currentAllocation(_ holdings: [Holding]) -> [AssetClass: Double] {
            let total = totalValue(holdings)
            guard total > 0 else { return [:] }

            var totals: [AssetClass: Double] = [:]
            for holding in holdings {
                totals[holding.assetClass, default: 0] += holding.value
            }

            return totals.mapValues { $0 / total }
        }
    
    static func drift(
        current: [AssetClass: Double],
        target: [AssetClass: Double]
    ) -> [AssetClass: Double] {

        var result: [AssetClass: Double] = [:]
        for assetClass in AssetClass.allCases {
            let currentPercent = current[assetClass] ?? 0
            let targetPercent = target[assetClass] ?? 0
            result[assetClass] = currentPercent - targetPercent
        }
        return result
    }
    
    static func rebalanceCandidates(
        drift: [AssetClass: Double],
        threshold: Double = 0.05
    ) -> [AssetClass: Double] {
        drift.filter { abs($0.value) > threshold }
    }
    

    static func healthScore(holdings: [Holding], profile: FinancialProfile) -> HealthScore {
        guard totalValue(holdings) > 0 else {
                return HealthScore(overall: 0, assetClassCoverage: 0, riskAlignment: 0)
            }
        
        let current = currentAllocation(holdings)
        let target = profile.riskCategory.targetAllocation
        let driftValues = drift(current: current, target: target)

        // How many asset classes actually have money in them, out of 5 possible.
        let heldClasses = current.filter { $0.value > 0 }.count
        let coverageScore = min(100, Double(heldClasses) / Double(AssetClass.allCases.count) * 100)

        
        // Total absolute drift ranges 0...2.0 (two allocations can differ by at
        // most 2.0 in total absolute terms), so ×50 maps that range onto 100...0
        // exactly, with no clipping. (Previously ×100 assumed a 0...1.0 range,
        // which zeroed the score out far too easily.)
        
        // How far off-target the portfolio is, in total, across all classes.
        let totalAbsoluteDrift = driftValues.values.reduce(0) { $0 + abs($1) }
        let riskAlignmentScore = max(0, 100 - (totalAbsoluteDrift * 50))

        let overall = (coverageScore + riskAlignmentScore) / 2

        return HealthScore(overall: overall, assetClassCoverage: coverageScore, riskAlignment: riskAlignmentScore)
    }
    
    
    /// The N largest holdings by current value, descending.
    static func topHoldings(_ holdings: [Holding], limit: Int = 5) -> [Holding] {
        Array(holdings.sorted { $0.value > $1.value }.prefix(limit))
    }

    /// What fraction of total portfolio value the top N holdings represent -
    /// a simple, honestly-labeled concentration figure, not a weighted
    /// "concentration score" implying more statistical rigor than it has.
    static func concentrationShare(_ holdings: [Holding], topCount: Int = 5) -> Double {
        let total = totalValue(holdings)
        guard total > 0 else { return 0 }
        let topSum = topHoldings(holdings, limit: topCount).reduce(0) { $0 + $1.value }
        return topSum / total
    }
}
