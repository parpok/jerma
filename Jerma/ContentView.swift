//
//  ContentView.swift
//  Jerma
//
//  Created by Patryk Puciłowski on 05/06/2024.
//

import GoogleGenerativeAI
import SwiftUI

struct ContentView: View {
    @State private var Question: String = ""
    @State private var Question2: String = ""
    @State private var FinalResponse: String = ""
    @State private var PickedModel: ModelsAvailble = ModelsAvailble.gemini_1_5_flash

    var body: some View {
        VStack {
            NavigationStack {
                VStack {
                    VStack {
                        ScrollView {
                            if !Question2.isEmpty {
                                Text("You: \(Question2)")
                                    .multilineTextAlignment(.leading)
                                    .font(.headline)
                            }
                            Spacer()

                            if !FinalResponse.isEmpty {
                                Text("Ai says: \(FinalResponse)")
                                    .multilineTextAlignment(.leading)
                                    .font(.subheadline)
                                    .defaultScrollAnchor(.center)
                            }
                        }

                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).textSelection(.enabled).padding()
                    VStack {
                        HStack {
                            Button(action: { print("Add things") }, label: {
                                Image(systemName: "plus.square")
                            }).buttonStyle(.bordered)

                            TextField("AiQuestionBox", text: $Question, prompt: Text("Ask \(PickedModel.rawValue) something"), axis: .vertical).textFieldStyle(.roundedBorder)
                            Button {
                                Question2 = Question
                                Task {
                                    let response = try await model.generateContent(Question)
                                    if let text = response.text {
                                        print(text)
                                        FinalResponse = text
                                    }
                                    Question = ""
                                }
                            } label: {
                                Image(systemName: "paperplane")
                            }.buttonStyle(.borderedProminent)
                        }
                    }.imageScale(.large).buttonBorderShape(.roundedRectangle).frame(maxWidth: .infinity, alignment: .bottom).padding(EdgeInsets(top: 0, leading: 2.5, bottom: 20, trailing: 2.5))
                }.toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { print("Show history") }, label: {
                            Label(
                                title: { Text("Show history") },
                                icon: { Image(systemName: "list.bullet") }
                            )
                        })
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            ForEach(ModelsAvailble.allCases) { model in
                                Button {
                                    PickedModel = model
                                } label: {
                                    if model == PickedModel {
                                        Image(systemName: "checkmark")
                                        Text(model.rawValue)
                                    } else {
                                        Text(model.rawValue)
                                    }
                                }
                            }
                        } label: {
                            Label(
                                title: { Text("Choose model") },
                                icon: { Image(systemName: "sparkles") }
                            )
                        }
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