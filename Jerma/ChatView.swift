//
//  ChatView.swift
//  Jerma
//
//  Created by Patryk Puciłowski on 07/06/2024.
//

import GoogleGenerativeAI
import SwiftData
import SwiftUI

struct ChatView: View {
    @State private var ChosenModel: ModelsAvailble = .gemini_1_5_flash

    @State var ChatsArray: [[Role: String]] = []

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    ForEach(ChatsArray.indices, id: \.self) { index in
                        let dicks = ChatsArray[index]
                        ForEach(dicks.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { role in
                            if let message = dicks[role] {
                                HStack {
                                    if role.rawValue.capitalized == "User" {
                                        Text("You said:")
                                            .font(.headline)
                                            .frame(maxHeight: .infinity, alignment: .topLeading)
                                        Text(try! AttributedString(markdown: message))
                                            .font(.body)
                                            .multilineTextAlignment(.leading)
                                            .defaultScrollAnchor(.leading)
                                            .frame(maxWidth: .infinity, alignment: .topLeading)
                                    } else {
                                        Text("\(role.rawValue.capitalized) said:")
                                            .font(.headline)
                                            .frame(maxHeight: .infinity, alignment: .topLeading)

                                        Text(try! AttributedString(markdown: message))
                                            .font(.body)
                                            .multilineTextAlignment(.leading)
                                            .defaultScrollAnchor(.leading)
                                            .frame(maxWidth: .infinity, alignment: .topLeading)
                                    }
                                }
                                Spacer()
                            }
                        }

                        // Thanks ChatGPT for this cursed AF solution
                    }

                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                #if targetEnvironment(simulator)
//                    .border(Color.blue)
                #endif

                AskAiView(chatArray: $ChatsArray)
                #if targetEnvironment(simulator)
//                    .border(Color.green)
                #endif
            }.navigationTitle("GermaAiChat")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            ForEach(ModelsAvailble.allCases) { model in
                                Button {
                                    ChosenModel = model
                                } label: {
                                    if model == ChosenModel {
                                        Image(systemName: "checkmark")
                                        Text(model.rawValue)
                                    } else {
                                        Text(model.rawValue)
                                    }
                                }
                            }
                        } label: {
                            Label(title: { Text("Choose language model") }, icon: { Image(systemName: "sparkles") })
                        }
                    }
                }
        }
    }
}

#Preview {
    ChatView()
}

