//
//  FollowUpExchange.swift
//  PortfolioManager
//
//  One question-and-answer turn in an Insights follow-up thread, plus the
//  next layer of suggested questions the AI offered based on that answer.

import Foundation

struct FollowUpExchange: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    let suggestedQuestions: [String]
}
