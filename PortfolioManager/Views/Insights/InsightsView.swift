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

    /// True once the live portfolio/profile no longer matches what the
    /// current review was generated from.
    private var isReviewOutdated: Bool {
        guard let profile = profiles.first, let reviewedSignature = vm.reviewedSignature else { return false }
        return InsightsViewModel.signature(holdings: holdings, profile: profile) != reviewedSignature
    }

    private var canAskFollowUp: Bool {
        vm.isSessionActive && !isReviewOutdated
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let explanation = vm.explanation {
                        sectionCard(title: "Overview") {
                            Text(explanation.overview)
                                .foregroundStyle(AppColors.textPrimary)
                        }

                        sectionCard(title: "Insights") {
                            ForEach(explanation.insights, id: \.self) { insight in
                                Text("• \(insight)")
                                    .foregroundStyle(AppColors.textPrimary)
                            }
                        }

                        sectionCard(title: "Recommendations") {
                            ForEach(explanation.recommendations, id: \.self) { recommendation in
                                Text(recommendation)
                                    .padding(10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(AppColors.tint)
                                    .foregroundStyle(AppColors.tintOn)
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
                                    sectionCard(title: "Ask about your portfolio") {
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

    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
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
                Image(systemName: "bubble.left.fill").font(.caption)
                Text(question).font(.footnote)
                Spacer(minLength: 0)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.background)
            .foregroundStyle(AppColors.action)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.border, lineWidth: 0.5))
        }
        .buttonStyle(.borderless)
    }
}
