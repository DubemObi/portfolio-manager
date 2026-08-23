//
//  SettingsView.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 23/08/2026.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var profiles: [FinancialProfile]
    @AppStorage("themeToggle") private var themeToggleRaw: String = ThemeToggle.light.rawValue
    @State private var isShowingEditProfile = false

    private var profile: FinancialProfile? { profiles.first }
    private var currentTheme: ThemeToggle { ThemeToggle(rawValue: themeToggleRaw) ?? .light }

    var body: some View {
        NavigationStack {
            List {
                Section("Your details") {
                    if let profile {
                        infoRow("Name", profile.name.isEmpty ? "Not set" : profile.name)
                        infoRow("Risk tolerance", profile.riskCategory.displayName)
                        infoRow("Goal", goalDisplayText(for: profile))
                        if let targetAmount = profile.targetAmount {
                            infoRow(
                                "Target amount",
                                targetAmount.formatted(
                                    .currency(code: "GBP")
                                    .precision(.fractionLength(0))
                                )
                            )
                        }
                    }
                }
                .listRowBackground(AppColors.card)

                Section {
                    Button {
                        isShowingEditProfile = true
                    } label: {
                        HStack {
                            Image(systemName: "pencil.circle.fill").font(.title3)
                            Text("Edit profile").fontWeight(.semibold)
                            Spacer()
                        }
                        .foregroundStyle(AppColors.actionOn)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.borderless)
                }
                .listRowBackground(AppColors.action)

                Section("Appearance") {
                    HStack {
                        Text("Theme").foregroundStyle(AppColors.textPrimary)
                        Spacer()
                        Button {
                            themeToggleRaw = currentTheme.opposite.rawValue
                        } label: {
                            Image(systemName: currentTheme.icon)
                                .font(.title3)
                                .foregroundStyle(AppColors.textPrimary)
                                .padding(8)
                                .background(AppColors.tint)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .listRowBackground(AppColors.card)

                Section("About") {
                    infoRow("Version", Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    Text("PortfolioManager helps you track a simulated investment portfolio, understand its health, and get explainable, on-device guidance - entirely offline-first.")
                        .font(.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .listRowBackground(AppColors.card)
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
            .navigationTitle("Profile")
            .sheet(isPresented: $isShowingEditProfile) {
                ThemedSheet { OnboardingView() }
            }
        }
    }

    private func goalDisplayText(for profile: FinancialProfile) -> String {
        if profile.financialGoal == .somethingElse, let custom = profile.customGoalDescription, !custom.isEmpty {
            return custom
        }
        return profile.financialGoal.displayName
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(AppColors.textPrimary)
            Spacer()
            Text(value).foregroundStyle(AppColors.textSecondary)
        }
    }
}
