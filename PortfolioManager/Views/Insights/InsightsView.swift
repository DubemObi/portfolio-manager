//
//  InsightsView.swift
//  PortfolioManager
//

import SwiftUI
import SwiftData

struct InsightsView: View {
    @Query private var holdings: [Holding]
    @Query private var profiles: [FinancialProfile]
    @State private var vm = InsightsViewModel()

    private var askedQuestions: Set<String> {
        Set(vm.followUps.map(\.question))
    }

    private var isReviewOutdated: Bool {
        guard let profile = profiles.first, let reviewedSignature = vm.reviewedSignature else { return false }
        return InsightsViewModel.signature(holdings: holdings, profile: profile) != reviewedSignature
    }
    
    private var aiUnavailableReason: String? {
        AIAvailability.reasonIfUnavailable
    }

    private var canAskFollowUp: Bool {
        vm.isSessionActive && !isReviewOutdated
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let aiUnavailableReason {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .font(.caption)
                                .foregroundStyle(AppColors.tintOn)
                            Text(aiUnavailableReason)
                                .font(.footnote)
                                .foregroundStyle(AppColors.tintOn)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.tint)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    if let explanation = vm.explanation {
                        sectionCard(icon: "sparkles", title: "Overview") {
                            Text(explanation.overview)
                                .foregroundStyle(AppColors.textPrimary)
                        }

                        sectionCard(icon: "lightbulb.fill", title: "Insights") {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(explanation.insights, id: \.self) { insight in
                                    HStack(alignment: .top, spacing: 8) {
                                        Circle()
                                            .fill(AppColors.brand)
                                            .frame(width: 6, height: 6)
                                            .padding(.top, 6)
                                        Text(insight).foregroundStyle(AppColors.textPrimary)
                                    }
                                }
                            }
                        }

                        sectionCard(icon: "arrow.up.right.circle.fill", title: "Recommendations") {
                            ForEach(explanation.recommendations, id: \.self) { recommendation in
                                Text(recommendation)
                                    .padding(10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(AppColors.brand.opacity(0.10))
//                                    .foregroundStyle(AppColors.brand)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }

                        if explanation.source == .ai {
                            if isReviewOutdated {
                                outdatedBanner
                            }

                            if canAskFollowUp && !vm.isLoading {
                                let initialQuestions = explanation.suggestedQuestions.filter { !askedQuestions.contains($0) }
                                if !initialQuestions.isEmpty {
                                    sectionCard(icon: "bubble.left.and.bubble.right.fill", title: "Ask about your portfolio") {
                                        VStack(spacing: 8) {
                                            ForEach(initialQuestions, id: \.self) { question in
                                                questionChip(question) {
                                                    Task { await vm.askFollowUp(question) }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            ForEach(vm.followUps) { exchange in
                                sectionCard(title: "You asked") {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(exchange.question)
                                            .font(.footnote).fontWeight(.semibold)
                                            .foregroundStyle(AppColors.textSecondary)
                                        Text(exchange.answer)
                                            .foregroundStyle(AppColors.textPrimary)

                                        if canAskFollowUp {
                                            let nextQuestions = exchange.suggestedQuestions.filter { !askedQuestions.contains($0) }
                                            if !nextQuestions.isEmpty {
                                                VStack(spacing: 8) {
                                                    ForEach(nextQuestions, id: \.self) { question in
                                                        questionChip(question) {
                                                            Task { await vm.askFollowUp(question) }
                                                        }
                                                    }
                                                }
                                                .padding(.top, 4)
                                            }
                                        }
                                    }
                                }
                            }

                            if vm.isAskingFollowUp {
                                HStack(spacing: 8) {
                                    ProgressView()
                                    Text("Thinking...").font(.footnote).foregroundStyle(AppColors.textSecondary)
                                }
                            }
                        }
                    } else if !vm.isLoading {
                        Text("Tap \"Review my portfolio\" to see how it's doing.")
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Button {
                        Task {
                            guard let profile = profiles.first else { return }
                            await vm.generate(holdings: holdings, profile: profile)
                        }
                    } label: {
                        HStack {
                            if vm.isLoading {
                                ProgressView()
                            } else {
                                Image(systemName: "sparkles")
                            }
                            Text(vm.isLoading ? "Reviewing..." : "Review my portfolio")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                    }
                    .background(AppColors.actionPrimary)
                    .foregroundStyle(AppColors.actionPrimaryOn)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(vm.isLoading || profiles.isEmpty)
                }
                .padding()
            }
            .background(AppColors.background)
            .navigationTitle("Insights")
            .onDisappear { vm.endSession() }
        }
    }

    private var outdatedBanner: some View {
        Text("Your portfolio has changed since this review - tap \"Review my portfolio\" for an up-to-date one.")
            .font(.footnote)
            .foregroundStyle(AppColors.warning)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.warningBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func sectionCard<Content: View>(icon: String? = nil, title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(AppColors.brand)
                }
                Text(title)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            content()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func questionChip(_ question: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "bubble.left.fill")
                    .font(.caption)
                    .foregroundStyle(AppColors.brand)
                Text(question)
                    .font(.footnote)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer(minLength: 0)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.brand.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.brand.opacity(0.25), lineWidth: 0.5))
        }
        .buttonStyle(.borderless)
    }
}
