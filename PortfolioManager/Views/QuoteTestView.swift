//
//  QuoteTestView.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 27/07/2026.
//

import SwiftUI

struct QuoteTestView: View {
    @State private var vm = PriceViewModel()

    var body: some View {
        VStack(spacing: 16) {
            if vm.isLoading {
                ProgressView()
            } else {
                Text(vm.priceText)
                PortfolioView()
            }

            Button("Fetch AAPL price") {
                Task {
                    await vm.loadPrice(symbol: "AAPL")
                }
            }
            .disabled(vm.isLoading)
        }
        .padding()
    }

    
}
