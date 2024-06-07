//
//  ContentView.swift
//  Jerma
//
//  Created by Patryk Puciłowski on 05/06/2024.
//

import GoogleGenerativeAI
import SwiftUI

struct ContentView: View {
    @State private var question: String = ""
    @State private var question2: String = ""
    @State private var FinalResponse: String = ""

    var body: some View {
        VStack {
            NavigationStack {
                VStack {
                    VStack {
                        if !question2.isEmpty {
                            Text("You: \(question2)")
                                .multilineTextAlignment(.leading)
                                .font(.headline)
                        }
                        Spacer()

                        Text(FinalResponse)
                            .multilineTextAlignment(.leading)
                            .font(.subheadline)

                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    VStack {
                        HStack {
                            Button(action: { print("Add things") }, label: {
                                Image(systemName: "plus.app")
                            })

                            TextField("AiQuestionBox", text: $question, prompt: Text("Ask it")).textFieldStyle(.roundedBorder)
                            Button {
                                question = question2
                                Task {
                                    let response = try await model.generateContent(question)
                                    if let text = response.text {
                                        print(text)
                                        FinalResponse = text
                                    }
                                }
                            } label: {
                                Image(systemName: "paperplane")
                            }
                        }
                    }.font(.title).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                }.toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { print("Show history") }, label: {
                            Image(systemName: "list.bullet")
                        })
                    }
                }
                .navigationTitle("Ai")
            }
        }
    }
}

#Preview {
    ContentView()
}
