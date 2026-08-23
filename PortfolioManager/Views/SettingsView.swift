//
//  SettingsView.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 23/08/2026.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var profiles: [FinancialProfile]
    @AppStorage("themeToggle") private var themeToggleRaw: String = ThemeToggle.system.rawValue
    @State private var isShowingEditProfile = false

    private var profile: FinancialProfile? { profiles.first }

    private var selectedTheme: Binding<ThemeToggle> {
        Binding(
            get: { ThemeToggle(rawValue: themeToggleRaw) ?? .system },
            set: { themeToggleRaw = $0.rawValue }
        )
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Profile") {
                    if let profile {
                        infoRow("Name", profile.name.isEmpty ? "Not set" : profile.name)
                        infoRow("Risk tolerance", profile.riskCategory.displayName)
                        infoRow("Goal", profile.financialGoal.displayName)
                    }
                    Button("Edit profile") { isShowingEditProfile = true }
                        .foregroundStyle(AppColors.action)
                }
                .listRowBackground(AppColors.card)

                Section("Appearance") {
                    ChipPicker(
                        title: "Theme",
                        options: ThemeToggle.allCases,
                        displayName: { $0.displayName },
                        selection: selectedTheme
                    )
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
            .navigationTitle("Settings")
            .sheet(isPresented: $isShowingEditProfile) { OnboardingView() }
        }
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(AppColors.textPrimary)
            Spacer()
            Text(value).foregroundStyle(AppColors.textSecondary)
        }
    }
}
