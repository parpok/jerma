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
                    }

                    if !ChatInputImages.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(0 ..< ChatInputImages.count, id: \.self) {
                                    i in
                                    ChatInputImages[i]
                                        .resizable()
                                        .scaledToFit()

                                }.frame(maxWidth: .infinity, maxHeight: 100)
                            }
                        }
                    }

                    if !AIAnswer.isEmpty {
                        Text("Ai says: \n \(AIAnswer)")
                            .multilineTextAlignment(.leading)
                            .font(.subheadline)
                            .defaultScrollAnchor(.leading)
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                AskAiView(UserQuestionSubmitted: UserPrompt, Answer: AIAnswer, ResultImages: ChatInputImages)
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
    @State var UserQuestionSubmitted: String = ""

    @State var Answer: String = ""

    @State private var ChosenImages = [PhotosPickerItem]()
    @State var ResultImages: [Image]

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

                Button {
                    Task {
                        let response = try await model.generateContent(UserQuestion)
                        if let text = response.text {
                            print(text)
                            Answer = text
                        }
                        UserQuestionSubmitted = UserQuestion
                    }
                } label: {
                    Image(systemName: "paperplane")
                }.buttonStyle(.borderedProminent)

            }.padding(EdgeInsets(top: 0, leading: 2.5, bottom: 20, trailing: 2.5))

        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

#Preview("AI Chat component") {
    AskAiView(Answer: "This is a preview. Hello there ya curious buddy", ResultImages: [Image(.car)])
}
