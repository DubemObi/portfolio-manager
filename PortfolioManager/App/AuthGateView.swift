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
    @State private var authFailed = false

    var body: some View {
        if isUnlocked {
            RootFlowView()
        } else {
            VStack(spacing: 16) {
                Button("Unlock Portfolio") {
                    authenticate()
                }
                if authFailed {
                    Text("Authentication failed. Tap to try again.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .task {
                authenticate()
            }
        }
    }

    private func authenticate() {
        let context = LAContext()

        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "Unlock your portfolio"
        ) { success, _ in
            Task { @MainActor in
                isUnlocked = success
                authFailed = !success
            }
        }
    }
}
