import Foundation
import FoundationModels

struct OnDeviceAIExplanationProvider: ExplanationProvider {

    func explain(holdings: [Holding], profile: FinancialProfile) async -> PortfolioExplanation? {
        guard SystemLanguageModel.default.isAvailable else { return nil }

        let current = PortfolioHealthEngine.currentAllocation(holdings)
        let target = profile.riskCategory.targetAllocation
        let driftValues = PortfolioHealthEngine.drift(current: current, target: target)
        let candidates = PortfolioHealthEngine.rebalanceCandidates(drift: driftValues)
        let score = PortfolioHealthEngine.healthScore(holdings: holdings, profile: profile)
        let disposable = AffordabilityEngine.disposableIncome(
            income: profile.monthlyIncome,
            expenses: profile.monthlyExpenses,
            debtPayments: profile.monthlyDebtPayments
        )
        let staleNames = holdings.filter(\.isStale).map(\.name)   // ← new line


        let input = PortfolioExplanationInput(
            totalValue: PortfolioHealthEngine.totalValue(holdings),
            currentAllocation: current,
            rebalanceCandidates: candidates,
            healthScore: score,
            disposableIncome: disposable,
            staleHoldingNames: staleNames
            
            
        )

        let instructions = Instructions {
            "You are a financial portfolio explainer inside a personal finance app."
            "You never give specific buy/sell financial advice - only general observations about balance and diversification."
            "If any holdings are flagged as not recently updated, mention this as a caveat rather than treating those figures as fully reliable."
        }
        let session = LanguageModelSession(instructions: instructions)

        do {
            let response = try await session.respond(to: buildPrompt(from: input), generating: AIPortfolioExplanation.self)
            let ai = response.content
            return PortfolioExplanation(overview: ai.overview, insights: ai.insights, recommendations: ai.recommendations)
        } catch {
            print("On-device AI failed, falling back: \(error.localizedDescription)")
            return nil
        }
    }

    /// Private - this prompt-building logic only ever makes sense in the
    /// context of this provider, so it has no reason to be visible elsewhere.
    private func buildPrompt(from input: PortfolioExplanationInput) -> String {
        var lines: [String] = []

        lines.append("Portfolio total value: £\(String(format: "%.2f", input.totalValue))")
        lines.append("Overall health score: \(Int(input.healthScore.overall))/100 (diversification: \(Int(input.healthScore.assetClassCoverage)), risk alignment: \(Int(input.healthScore.riskAlignment)))")
        lines.append("Disposable income available for investing: £\(String(format: "%.2f", input.disposableIncome)) per month")

        lines.append("Current allocation:")
        for (assetClass, percent) in input.currentAllocation.sorted(by: { $0.value > $1.value }) {
            lines.append("- \(assetClass.displayName): \(Int(percent * 100))%")
        }

        if input.rebalanceCandidates.isEmpty {
            lines.append("The portfolio is closely aligned with its target allocation.")
        } else {
            lines.append("Asset classes significantly off target:")
            for (assetClass, drift) in input.rebalanceCandidates.sorted(by: { abs($0.value) > abs($1.value) }) {
                let direction = drift > 0 ? "overweight" : "underweight"
                lines.append("- \(assetClass.displayName) is \(direction) by \(Int(abs(drift) * 100)) percentage points")
            }
        }
        
        if !input.staleHoldingNames.isEmpty {
            lines.append("Note: the following holdings have not been revalued recently and may be inaccurate: \(input.staleHoldingNames.joined(separator: ", "))")
        }

        return lines.joined(separator: "\n")
    }
}
