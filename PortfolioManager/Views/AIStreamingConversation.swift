//
//  AIStreamingConversation.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 03/08/2026.
//
import SwiftUI
import SwiftData
import FoundationModels


struct AIStreamingConversation: View {
    @Environment(\.modelContext) private var context
    
    @State private var prompt = "Write a poem about a cat."
    @State private var response = ""
    @State private var vm = DashboardViewModel()
    
    @Query private var holdings: [Holding]
    
    //    var body: some View {
    //            VStack {
    //                Text(prompt)
    //
    //                Button("Create a poem"){
    //                    let session = LanguageModelSession()
    //
    //                    response = ""
    //
    //                    Task{
    //                        do{
    //                            for try await partialResponse in session.streamResponse(to: prompt){
    //                                response = partialResponse.content
    //                            }
    //                        }catch{
    //                            print("Foundation Models unavailable: \(error)")
    //                        }
    //                    }
    //                }.buttonStyle(.borderedProminent)
    //
    //                ScrollView{
    //                    Text(response).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).padding()
    //                }
    //
    //            }.font(.title)
    //    }
    
    var body: some View {
        VStack(spacing: 16) {
            if SystemLanguageModel.default.isAvailable {
                Text("On-device AI is ready")
                    .foregroundStyle(.green)
            } else {
                Text(availabilityMessage)
                    .foregroundStyle(.orange)
            }
            
        }
        .padding().onAppear() {
            vm.load(context: context)
        }
    }
    
    private var availabilityMessage: String {
        switch SystemLanguageModel.default.availability {
        case .available:
            return ""
        case .unavailable(.deviceNotEligible):
            return "This device doesn't support Apple Intelligence."
        case .unavailable(.appleIntelligenceNotEnabled):
            return "Apple Intelligence is turned off in Settings."
        case .unavailable(.modelNotReady):
            return "The on-device model is still downloading."
        case .unavailable(let reason):
            return "Unavailable: \(reason)"
        }
    }
    
    
}
