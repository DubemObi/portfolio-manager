//
//  RiskProfilingEngineTests.swift
//  PortfolioManagerTests
//

import XCTest
@testable import PortfolioManager

final class RiskProfilingEngineTests: XCTestCase {

    func test_classify_minimumScore_isConservative() {
        // 6 questions, lowest option (1) on every one = total 6.
        XCTAssertEqual(RiskProfilingEngine.classify(scores: [1, 1, 1, 1, 1, 1]), .conservative)
    }

    func test_classify_maximumScore_isAggressive() {
        // 6 questions, highest option (4) on every one = total 24.
        XCTAssertEqual(RiskProfilingEngine.classify(scores: [4, 4, 4, 4, 4, 4]), .aggressive)
    }

    func test_classify_midRangeScore_isModerate() {
        // Total 15 - comfortably inside the 12-18 moderate band.
        XCTAssertEqual(RiskProfilingEngine.classify(scores: [2, 3, 2, 3, 2, 3]), .moderate)
    }

    func test_classify_conservativeUpperBoundary() {
        // Total 11 - just inside conservative (band is ..<12).
        XCTAssertEqual(RiskProfilingEngine.classify(scores: [2, 2, 2, 2, 2, 1]), .conservative)
    }

    func test_classify_moderateLowerBoundary() {
        // Total 12 - the first value inside the moderate band.
        XCTAssertEqual(RiskProfilingEngine.classify(scores: [2, 2, 2, 2, 2, 2]), .moderate)
    }

    func test_classify_moderateUpperBoundary() {
        // Total 18 - the last value still inside the moderate band.
        XCTAssertEqual(RiskProfilingEngine.classify(scores: [3, 3, 3, 3, 3, 3]), .moderate)
    }

    func test_classify_aggressiveLowerBoundary() {
        // Total 19 - the first value that tips into aggressive.
        XCTAssertEqual(RiskProfilingEngine.classify(scores: [3, 3, 3, 3, 3, 4]), .aggressive)
    }

    func test_questions_hasSixQuestions_eachWithFourOptions() {
        XCTAssertEqual(RiskProfilingEngine.questions.count, 6)
        for question in RiskProfilingEngine.questions {
            XCTAssertEqual(question.options.count, 4)
        }
    }
}
