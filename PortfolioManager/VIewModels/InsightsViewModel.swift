//
//  InsightsViewModel.swift
//  PortfolioManager
//

import Foundation

@Observable
class InsightsViewModel {
    var explanation: PortfolioExplanation?
    var followUps: [FollowUpExchange] = []
    var isLoading = false
    var isAskingFollowUp = false

    /// True only while a live AI session exists to ask questions against.
    /// Becomes false after endSession() (leaving the screen) or if the
    /// underlying data has changed since the review was generated.
    var isSessionActive = false

    /// A snapshot of the portfolio/profile data at the moment the current
    /// review was generated - compared against the live data to detect
    /// "this review is now out of date" (see InsightsView).
    var reviewedSignature: String?

    private let aiProvider = OnDeviceAIExplanationProvider()

    func generate(holdings: [Holding], profile: FinancialProfile) async {
        isLoading = true
        followUps = []
        defer { isLoading = false }

        let result = await InsightsEngine.generate(aiProvider: aiProvider, holdings: holdings, profile: profile)
        explanation = result

        if result.source == .ai {
            isSessionActive = true
            reviewedSignature = Self.signature(holdings: holdings, profile: profile)
        } else {
            isSessionActive = false
            reviewedSignature = nil
        }
    }

    /// Asks the next question in the thread - a first-level question gets
    /// a normal answer with more questions; the second gets a concluding
    /// answer with none. followUps.count is the thread's current depth.
    func askFollowUp(_ question: String) async {
        isAskingFollowUp = true
        defer { isAskingFollowUp = false }

        let exchange: FollowUpExchange?
        if followUps.isEmpty {
            exchange = await aiProvider.askFollowUp(question)
        } else {
            exchange = await aiProvider.askFinalFollowUp(question)
        }

        if let exchange {
            followUps.append(exchange)
        }
    }

    /// Called from InsightsView's .onDisappear - frees the AI session and
    /// stops offering further questions against the now-ended thread.
    func endSession() {
        isSessionActive = false
        aiProvider.invalidateSession()
    }

    /// A cheap, stable fingerprint of everything the review/prompt actually
    /// depends on. If this differs from reviewedSignature, the portfolio
    /// has changed since the review was generated.
    static func signature(holdings: [Holding], profile: FinancialProfile) -> String {
        let holdingsPart = holdings
            .sorted(by: { (a: Holding, b: Holding) in (a.symbol ?? a.name) < (b.symbol ?? b.name) })
            .map { "\($0.symbol ?? $0.name):\($0.quantity):\($0.pricePerUnit):\($0.lastUpdated?.timeIntervalSince1970 ?? 0)" }
            .joined(separator: "|")

        let profilePart = "\(profile.monthlyIncome):\(profile.monthlyExpenses):\(profile.monthlyDebtPayments):\(profile.currentSavings):\(profile.riskCategory.rawValue)"

        return holdingsPart + "::" + profilePart
    }
}
