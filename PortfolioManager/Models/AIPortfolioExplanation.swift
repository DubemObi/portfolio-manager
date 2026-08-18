//
//  AIPortfolioExplanation.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 13/08/2026.
//

import FoundationModels

@Generable(description: "An explanation of a portfolio's health, in three parts")
struct AIPortfolioExplanation {
    @Guide(description: "One short sentence summarizing the portfolio's overall health, e.g. 'Your portfolio is well diversified but overweight in equities.'")
    var overview: String

    @Guide(description: "2-3 brief observations about the portfolio's current allocation")
    var insights: [String]

    @Guide(description: "1-3 general, non-prescriptive suggestions for improving balance - never specific buy/sell advice")
    var recommendations: [String]
}




