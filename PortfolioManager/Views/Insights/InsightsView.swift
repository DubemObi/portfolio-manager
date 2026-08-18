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
                    } else if !vm.isLoading {
                        Text("Tap \"Generate insights\" to see how your portfolio is doing.")
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
                            Text(vm.isLoading ? "Generating..." : "Generate insights")
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
        }
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
}
