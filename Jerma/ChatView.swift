//
//  ChatView.swift
//  Jerma
//
//  Created by Patryk Puciłowski on 07/06/2024.
//

import GoogleGenerativeAI
import PhotosUI
import SwiftUI

struct ChatView: View {
    @State private var Question: String = ""
    @State private var Question2: String = ""
    @State private var FinalResponse: String = ""

    @State private var chosenimages = [PhotosPickerItem]()
    @State private var images = [Image]()

    @State private var PickedModel: ModelsAvailble = ModelsAvailble.gemini_1_5_flash

    var body: some View {
        VStack {
            NavigationStack {
                VStack {
                    VStack {
                        ScrollView {
                            if !Question2.isEmpty {
                                LazyHStack {
                                    ForEach(0 ..< images.count, id: \.self) { i in
                                        images[i]
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                    }.frame(maxWidth: .infinity, maxHeight: 100)
                                }

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
                        VStack {
                            if !images.isEmpty {
                                Text("^[Including \(images.count) images:](inflect: true)")
                                    .foregroundStyle(.gray)
                                    .textCase(.uppercase)
                                    .font(.callout)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                                LazyHStack {
                                    ForEach(0 ..< images.count, id: \.self) { i in
                                        images[i]
                                            .resizable()
                                            .scaledToFit()

                                    }.frame(maxWidth: .infinity, maxHeight: 100, alignment: .bottom)
                                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                            }

                        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

                        HStack {
                            PhotosPicker(selection: $chosenimages) {
                                Image(systemName: "plus.square")
                            }.buttonStyle(.bordered)
                                .onChange(of: chosenimages) { newItems in
                                    Task {
                                        images.removeAll()

                                        for item in newItems {
                                            if let image = try? await item.loadTransferable(type: Image.self) {
                                                images.append(image)
                                            }
                                        }
                                    }
                                }

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
    ChatView()
}
