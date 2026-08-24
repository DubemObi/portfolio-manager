//
//  OnDeviceAIExplanationProvider.swift
//  PortfolioManager
//
//  A class, not a struct - it holds a live LanguageModelSession after
//  explain() returns, so follow-up questions continue the same
//  conversation. One instance is owned by InsightsViewModel for the
//  lifetime of a review-and-follow-up thread, and explicitly discarded
//  via invalidateSession() when that thread ends (see InsightsViewModel).
//

import Foundation
import FoundationModels

final class OnDeviceAIExplanationProvider: ExplanationProvider {
    private var session: LanguageModelSession?

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
        let staleNames = holdings.filter(\.isStale).map(\.name)

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
            "The user may ask up to two follow-up questions about this portfolio. Answer the first naturally, offering further questions. The second follow-up answer should read as a concluding remark that wraps up the conversation."
        }
        let newSession = LanguageModelSession(instructions: instructions)

        do {
            let response = try await newSession.respond(to: buildPrompt(from: input), generating: AIPortfolioExplanation.self)
            let ai = response.content
            session = newSession
            return PortfolioExplanation(
                overview: ai.overview,
                insights: ai.insights,
                recommendations: ai.recommendations,
                source: .ai,
                suggestedQuestions: ai.suggestedQuestions
            )
        } catch {
            print("On-device AI failed, falling back: \(error.localizedDescription)")
            session = nil
            return nil
        }
    }

    /// First-level follow-up: answers the question and offers a second
    /// layer of questions.
    func askFollowUp(_ question: String) async -> FollowUpExchange? {
        guard let session else { return nil }

        do {
            let response = try await session.respond(to: question, generating: AIFollowUpAnswer.self)
            let result = response.content
            return FollowUpExchange(question: question, answer: result.answer, suggestedQuestions: result.suggestedQuestions)
        } catch {
            print("Follow-up question failed: \(error.localizedDescription)")
            return nil
        }
    }

    /// Second-level follow-up: the last one allowed in a thread. Uses
    /// AIFollowUpConclusion, which has no suggestedQuestions field at all -
    /// the conversation can't branch a third time by construction, not
    /// just because the UI chooses to hide something.
    func askFinalFollowUp(_ question: String) async -> FollowUpExchange? {
        guard let session else { return nil }

        let prompt = "This is the final follow-up question in this conversation. Answer it and wrap up the discussion with a concluding tone: \(question)"

        do {
            let response = try await session.respond(to: prompt, generating: AIFollowUpConclusion.self)
            let result = response.content
            return FollowUpExchange(question: question, answer: result.answer, suggestedQuestions: [])
        } catch {
            print("Final follow-up question failed: \(error.localizedDescription)")
            return nil
        }
    }

    /// Explicitly ends the conversation, freeing the session. Called when
    /// the user leaves Insights (see InsightsView's .onDisappear) - the
    /// TabView keeps this ViewModel alive across tab switches, so nothing
    /// would free this on its own without an explicit call.
    func invalidateSession() {
        session = nil
    }

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
