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
    @State private var ChosenModel: ModelsAvailble = .gemini_1_5_flash

    @State private var AIAnswer: String = ""

    @State private var ChatInputImages = [Image]()

    @State private var UserPrompt: String = ""
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    if !UserPrompt.isEmpty {
                        Text("You: \n \(UserPrompt)")
                            .multilineTextAlignment(.leading)
                            .font(.subheadline)
                            .defaultScrollAnchor(.leading)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                    }

                    if !ChatInputImages.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(0 ..< ChatInputImages.count, id: \.self) {
                                    i in
                                    ChatInputImages[i]
                                        .resizable()
                                        .scaledToFit()

                                }.frame(maxWidth: .infinity, maxHeight: 100, alignment: .topLeading)
                            }
                        }
                    }

                    Spacer()

                    if !AIAnswer.isEmpty {
                        Text("Ai says: \n \(AIAnswer)")
                            .multilineTextAlignment(.leading)
                            .font(.subheadline)
                            .defaultScrollAnchor(.leading)
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                AskAiView(UserQuestionSubmitted: $UserPrompt, Answer: $AIAnswer, ResultImages: $ChatInputImages)
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

struct AskAiView: View {
    @State private var UserQuestion: String = ""
    @Binding var UserQuestionSubmitted: String

    @Binding var Answer: String

    @State private var ChosenImages = [PhotosPickerItem]()
    @Binding var ResultImages: [Image]

    var body: some View {
        VStack {
            if !ResultImages.isEmpty {
                VStack {
                    Text("^[Including \(ResultImages.count) images:](inflect: true)").foregroundStyle(.gray).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(0 ..< ResultImages.count, id: \.self) {
                                i in
                                ResultImages[i]
                                    .resizable()
                                    .scaledToFit()

                            }.frame(maxWidth: .infinity, maxHeight: 100)
                        }
                    }
                }
            }
            HStack {
                PhotosPicker(selection: $ChosenImages) {
                    Image(systemName: "plus.square")
                }.buttonStyle(.bordered)
                    .onChange(of: ChosenImages) { _, newItems in
                        Task {
                            ResultImages.removeAll()

                            for item in newItems {
                                if let image = try? await item.loadTransferable(type: Image.self) {
                                    ResultImages.append(image)
                                }
                            }
                        }
                    }
                TextField("Ask something", text: $UserQuestion, axis: .vertical)
                    .textFieldStyle(.roundedBorder).onKeyPress(.return, action: {
                        UserQuestionSubmitted = UserQuestion
                        UserQuestion = ""
                        Task {
                            let response = try await model.generateContent(UserQuestion)
                            if let text = response.text {
                                print(text)
                                Answer = text
                            }
                        }
                        return .handled
                    })

                Button {
                    UserQuestionSubmitted = UserQuestion
                    UserQuestion = ""
                    Task {
                        let response = try await model.generateContent(UserQuestion)
                        if let text = response.text {
                            print(text)
                            Answer = text
                        }
                    }
                } label: {
                    Image(systemName: "paperplane")
                }.buttonStyle(.borderedProminent)

            }.padding(EdgeInsets(top: 0, leading: 2.5, bottom: 20, trailing: 2.5))

        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

struct AskingAIPreview: PreviewProvider {
    @State static var Question = "Hello, U up"
    @State static var Answer = "This is a test"
    @State static var Images = [Image(.car)]

    static var previews: some View {
        AskAiView(UserQuestionSubmitted: $Question, Answer: $Answer, ResultImages: $Images)
    }
}
