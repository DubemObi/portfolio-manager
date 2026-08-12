//
//  AIStreamingConversation.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 03/08/2026.
//
import SwiftUI
import FoundationModels


struct AIStreamingConversation: View {
    @State private var prompt = "Write a poem about a cat."
    @State private var response = ""
    
    var body: some View {
            VStack {
                Text(prompt)
                
                Button("Create a poem"){
                    let session = LanguageModelSession()
                    
                    response = ""
                    
                    Task{
                        do{
                            for try await partialResponse in session.streamResponse(to: prompt){
                                response = partialResponse.content
                            }
                        }catch{
                            print("Foundation Models unavailable: \(error)")
                        }
                    }
                }.buttonStyle(.borderedProminent)
                
                ScrollView{
                    Text(response).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).padding()
                }
                
            }.font(.title)
    }
}
