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
                        infoRow(icon: "person.fill", label: "Name", value: profile.name.isEmpty ? "Not set" : profile.name)

                        HStack {
                            Image(systemName: profile.riskCategory.icon)
                                .frame(width: 22)
                                .foregroundStyle(profile.riskCategory.color)
                            Text("Risk tolerance").foregroundStyle(AppColors.textPrimary)
                            Spacer()
                            Text(profile.riskCategory.displayName)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(profile.riskCategory.colorBackground)
                                .foregroundStyle(profile.riskCategory.color)
                                .clipShape(Capsule())
                        }

                        infoRow(icon: "flag.fill", label: "Goal", value: goalDisplayText(for: profile))

                        if let targetAmount = profile.targetAmount {
                            infoRow(icon: "target", label: "Target amount", value: targetAmount.formatted(
                                .currency(code: "GBP")
                                    .precision(.fractionLength(0)))
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
                        .foregroundStyle(AppColors.actionPrimaryOn)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.borderless)
                }
                .listRowBackground(AppColors.actionPrimary)

                Section("Appearance") {
                    HStack {
                        Text("Theme").foregroundStyle(AppColors.textPrimary)
                        Spacer()
                        Button {
                            themeToggleRaw = currentTheme.opposite.rawValue
                        } label: {
                            Image(systemName: currentTheme.icon)
                                .font(.title3)
                                .foregroundStyle(AppColors.brand)
                                .padding(8)
                                .background(AppColors.brand.opacity(0.12))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .listRowBackground(AppColors.card)

                Section("About") {
                    infoRow(icon: "info.circle.fill", label: "Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
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

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 22)
                .foregroundStyle(AppColors.brand)
            Text(label).foregroundStyle(AppColors.textPrimary)
            Spacer()
            Text(value).foregroundStyle(AppColors.textSecondary)
        }
    }
}
