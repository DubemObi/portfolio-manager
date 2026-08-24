//
//  AIAvailability.swift
//  PortfolioManager
//
//  A thin, UI-facing translation of SystemLanguageModel's own availability
//  reason into plain English. Kept separate from OnDeviceAIExplanationProvider
//  deliberately - the provider's own guard (isAvailable) is unchanged and
//  still decides whether AI actually runs; this is purely for explaining
//  *why* to the user when it doesn't; never used to block anything.
//

import FoundationModels

enum AIAvailability {
    /// nil means AI is available - nothing to show. Otherwise, a short,
    /// specific, non-alarming sentence explaining what's missing.
    static var reasonIfUnavailable: String? {
        switch SystemLanguageModel.default.availability {
        case .available:
            return nil

        case .unavailable(.deviceNotEligible):
            return "AI-generated insights need a newer iPhone. You'll see rule-based insights instead - these still cover everything, just without AI's natural-language explanations."

        case .unavailable(.appleIntelligenceNotEnabled):
            return "Turn on Apple Intelligence in Settings to get AI-generated insights. You'll see rule-based insights for now."

        case .unavailable(.modelNotReady):
            return "The on-device AI model is still downloading or isn't ready yet. You'll see rule-based insights for now - check back shortly."

        case .unavailable:
            return "AI-generated insights aren't available right now. You'll see rule-based insights instead."

        @unknown default:
            return "AI-generated insights aren't available right now. You'll see rule-based insights instead."
        }
    }
}
