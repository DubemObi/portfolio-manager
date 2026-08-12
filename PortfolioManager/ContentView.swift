//
//  ContentView.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 18/07/2026.
//

import SwiftUI
import SwiftData
import Foundation


struct ContentView: View {
    var body: some View {
        TabView{
            DashboardView().tabItem {
                Label("Dashboard", systemImage: "gauge.with.dots.needle.67percent")
            }
            PortfolioView().tabItem {
                Label("Portfolio", systemImage: "chart.pie.fill")
            }
            OnboardingView().tabItem {
                Label("Onboarding`", systemImage: "chart.pie.fill")
            }
            AddHoldingView().tabItem {
                Label("AddHolding`", systemImage: "chart.bar.fill")
            }

//            Button("Check Affordability"){
//                print(AffordabilityEngine.disposableIncome(income: 3200, expenses: 2100, debtPayments: 250))
//            }
//            
//            List(holdings){ holding in
//                Text("\(holding.name): £\(holding.value, specifier: "%.2f")")
//            }
//            
//            TextField("Holding name", text: $newName).textFieldStyle(.roundedBorder)
//            
//            TextField("Value", text: $newValue).keyboardType(.decimalPad).textFieldStyle(.roundedBorder)
//            
//            Button("Save a holding") {
//                guard let valueAsNumber = Double(newValue), !newName.isEmpty else { return }
//                let holding = Holding (name: newName, value : valueAsNumber)
//                context.insert(holding)
//                newName = ""
//                newValue = ""
//                
//            }
            
            
//            if let profile = profiles.first {
//            let disposable = AffordabilityEngine.disposableIncome(
//                                income: profile.monthlyIncome,
//                                expenses: profile.monthlyExpenses,
//                                debtPayments: 0
//                            )
//                            Text("Disposable income: £\(disposable, specifier: "%.2f")")
//                        } else {
//                            Text("No financial profile saved yet")
//                        }
        
        }
            
        }
    }





#Preview {
    ContentView()
}
