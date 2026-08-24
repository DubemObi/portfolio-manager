//
//  AIPortfolioExplanation.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 13/08/2026.
//

import FoundationModels

@Generable(description: "An explanation of a portfolio's health, in three parts, plus follow-up questions the user could ask")
struct AIPortfolioExplanation {
    @Guide(description: "One short sentence summarizing the portfolio's overall health, e.g. 'Your portfolio is well diversified but overweight in equities.'")
    var overview: String

    @Guide(description: "2-3 brief observations about the portfolio's current allocation")
    var insights: [String]

    @Guide(description: "1-3 general, non-prescriptive suggestions for improving balance - never specific buy/sell advice")
    var recommendations: [String]

    @Guide(description: "2-3 natural follow-up questions the user might want to ask about this portfolio, written from the user's point of view, e.g. 'Why is my portfolio overweight in equities?'")
    var suggestedQuestions: [String]
}

/// The AI's response to a single follow-up question - an answer, plus the
/// next layer of questions the user might reasonably ask next.
@Generable(description: "An answer to a user's follow-up question about their portfolio, plus further questions they might ask next")
struct AIFollowUpAnswer {
    @Guide(description: "A clear, conversational answer to the user's question, grounded in the portfolio data already discussed. Never specific buy/sell advice.")
    var answer: String

    @Guide(description: "2-3 natural follow-up questions the user might want to ask next, based on this answer")
    var suggestedQuestions: [String]
}

/// The AI's response to the final follow-up question in a thread - a
/// concluding answer, deliberately with no suggestedQuestions field, so
/// the conversation structurally cannot branch a third time.
@Generable(description: "A concluding answer that wraps up a follow-up conversation about a portfolio, with no further questions offered")
struct AIFollowUpConclusion {
    @Guide(description: "A clear, conversational answer to the user's final question, grounded in everything discussed so far, that wraps up the conversation. Never specific buy/sell advice.")
    var answer: String
}

