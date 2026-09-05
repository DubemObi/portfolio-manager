//
//  RiskProfilingEngine.swift
//  PortfolioManager
//
//  A pure, stateless classifier - same pattern as PortfolioHealthEngine and
//  AffordabilityEngine. Raw quiz answers are never persisted; only the
//  resulting RiskCategory is (via the existing FinancialProfile field),
//  so no new SwiftData model or migration is needed.
//

import Foundation

struct RiskQuizOption: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let score: Int
}

struct RiskQuizQuestion: Identifiable {
    let id = UUID()
    let prompt: String
    let options: [RiskQuizOption]
}

struct RiskProfilingEngine {

    /// 6 questions, each scored 1-4, giving a possible total range of 6-24.
    static let questions: [RiskQuizQuestion] = [
        RiskQuizQuestion(prompt: "When do you expect to need this money?", options: [
            RiskQuizOption(text: "Within 1 year", score: 1),
            RiskQuizOption(text: "1-3 years", score: 2),
            RiskQuizOption(text: "3-7 years", score: 3),
            RiskQuizOption(text: "7+ years", score: 4)
        ]),
        RiskQuizQuestion(prompt: "If your portfolio suddenly dropped 20% in value, what would you most likely do?", options: [
            RiskQuizOption(text: "Sell everything to avoid further loss", score: 1),
            RiskQuizOption(text: "Sell some to reduce risk", score: 2),
            RiskQuizOption(text: "Do nothing and wait it out", score: 3),
            RiskQuizOption(text: "Buy more while prices are low", score: 4)
        ]),
        RiskQuizQuestion(prompt: "How would you describe your investing experience?", options: [
            RiskQuizOption(text: "None", score: 1),
            RiskQuizOption(text: "A little - familiar with the basics", score: 2),
            RiskQuizOption(text: "Comfortable - I've invested before", score: 3),
            RiskQuizOption(text: "Experienced - I invest regularly", score: 4)
        ]),
        RiskQuizQuestion(prompt: "Which best describes your investing priority?", options: [
            RiskQuizOption(text: "Preserve my capital, minimal risk", score: 1),
            RiskQuizOption(text: "Mostly preserve capital, a little growth", score: 2),
            RiskQuizOption(text: "A balance of growth and safety", score: 3),
            RiskQuizOption(text: "Maximise growth, comfortable with risk", score: 4)
        ]),
        RiskQuizQuestion(prompt: "How much of a temporary loss could you tolerate without panicking?", options: [
            RiskQuizOption(text: "Any loss is very uncomfortable", score: 1),
            RiskQuizOption(text: "Up to 10%", score: 2),
            RiskQuizOption(text: "Up to 25%", score: 3),
            RiskQuizOption(text: "More than 25%, for likely long-term gains", score: 4)
        ]),
        RiskQuizQuestion(prompt: "How stable is your income and financial situation?", options: [
            RiskQuizOption(text: "Unstable or uncertain", score: 1),
            RiskQuizOption(text: "Somewhat stable", score: 2),
            RiskQuizOption(text: "Stable", score: 3),
            RiskQuizOption(text: "Very stable, with a solid savings buffer", score: 4)
        ])
    ]

    /// Classifies a completed quiz from the summed scores of selected
    /// answers. Boundaries split the 6-24 possible range into three
    /// roughly even bands (6-11 / 12-18 / 19-24).
    
    static func classify(scores: [Int]) -> FinancialProfile.RiskCategory {
        let total = scores.reduce(0, +)
        switch total {
        case ..<12: return .conservative
        case 12...18: return .moderate
        default: return .aggressive
        }
    }
}
