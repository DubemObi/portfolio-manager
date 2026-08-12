//
//  AuthGateView.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 22/07/2026.
//

import SwiftUI
import LocalAuthentication

struct AuthGateView: View {
    @State private var isUnlocked = false

    var body: some View {
        if isUnlocked {
            ContentView()
        } else {
            Button("Unlock with Face ID") {
                authenticate()
            }
            .task {
                authenticate()
            }
        }
    }

    private func authenticate() {
        let context = LAContext()

        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Unlock your portfolio"
        ) { success, _ in
            Task { @MainActor in
                isUnlocked = success
            }
        }
    }
}
