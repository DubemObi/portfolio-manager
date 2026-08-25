//
//  AlertsView.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 19/08/2026.
//

import SwiftUI
import SwiftData

struct AlertsView: View {
    @Environment(\.modelContext) private var context
    @Query private var holdings: [Holding]
    @Query private var profiles: [FinancialProfile]
    @Query(sort: \RebalanceDecision.decidedAt, order: .reverse) private var decisions: [RebalanceDecision]
    @State private var vm = AlertsViewModel()

    private var profile: FinancialProfile? { profiles.first }

    private var healthScore: Double {
        guard let profile else { return 0 }
        return PortfolioHealthEngine.healthScore(holdings: holdings, profile: profile).overall
    }

    private var pending: [AssetClass: Double] {
        guard let profile, !holdings.isEmpty else { return [:] }
        let current = PortfolioHealthEngine.currentAllocation(holdings)
        let target = profile.riskCategory.targetAllocation
        let drift = PortfolioHealthEngine.drift(current: current, target: target)
        let candidates = PortfolioHealthEngine.rebalanceCandidates(drift: drift)
        return AlertsEngine.pendingAlerts(candidates: candidates, decisions: decisions)
    }

    var body: some View {
        NavigationStack {
            List {
                if let lastErrorMessage = vm.lastErrorMessage {
                    Text(lastErrorMessage)
                        .font(.footnote)
                        .foregroundStyle(AppColors.warning)
                        .listRowBackground(AppColors.warningBackground)
                }

                if pending.isEmpty && decisions.isEmpty {
                    EmptyStateView(icon: "checkmark.circle", message: "No rebalancing suggestions right now.")
                } else {
                    ForEach(Array(pending.keys), id: \.self) { assetClass in
                        pendingRow(assetClass: assetClass, drift: pending[assetClass] ?? 0)
                    }

                    ForEach(decisions) { decision in
                        historyRow(decision)
                    }
                }
            }
            .listRowBackground(AppColors.card)
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
            .navigationTitle("Alerts")
        }
    }

    private func pendingRow(assetClass: AssetClass, drift: Double) -> some View {
        let direction = drift > 0 ? "reducing" : "increasing"
        let driftPercent = Int(abs(drift) * 100)

        return VStack(alignment: .leading, spacing: 10) {
            Group {
                Text("Rebalance suggested").font(.subheadline).fontWeight(.semibold).foregroundStyle(AppColors.textPrimary)
                Text("\(assetClass.displayName) has drifted \(driftPercent) points from target. Consider \(direction) this allocation.")
                    .font(.footnote)
                    .foregroundStyle(AppColors.textSecondary)

                HStack(spacing: 8) {
                    Button("Accept") { decide(assetClass, drift, .accepted) }
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.actionPrimary)
                        .foregroundStyle(AppColors.actionPrimaryOn)

                    Button("Snooze") { decide(assetClass, drift, .snoozed) }
                        .buttonStyle(.bordered)
                        .tint(AppColors.action)

                    Button("Decline") { decide(assetClass, drift, .declined) }
                        .buttonStyle(.bordered)
                        .tint(AppColors.action)
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 8)
        .listRowSeparator(.hidden)
        .overlay(alignment: .leading) {
            Rectangle().fill(AppColors.warning).frame(width: 3)
        }
    }

    private func historyRow(_ decision: RebalanceDecision) -> some View {
        let change = healthScore - decision.healthScoreAtDecision
        let changeText = change >= 0
            ? "Health score rose by \(Int(change)) points since."
            : "Health score fell by \(Int(abs(change))) points since."

        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(decision.decision == .accepted ? "Rebalance accepted" : decision.decision == .declined ? "Rebalance declined" : "Rebalance snoozed")
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(decision.decision == .accepted ? AppColors.success : AppColors.textPrimary)
                Spacer()
                Text(decision.decidedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2).foregroundStyle(AppColors.textSecondary)
            }
            if decision.decision == .accepted {
                Text(changeText).font(.footnote).foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(.vertical, 6)
        .listRowSeparator(.hidden)
    }

    private func decide(_ assetClass: AssetClass, _ drift: Double, _ decision: RebalanceDecision.Decision) {
        vm.recordDecision(assetClass: assetClass, drift: drift, healthScore: healthScore, decision: decision, context: context)
    }
}
