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

    @State private var ChatInputImage = Data()

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

                    if !ChatInputImage.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                Image(uiImage: UIImage(data: ChatInputImage)!)
                                    .resizable()
                                    .scaledToFit()

                            }.frame(maxWidth: .infinity, maxHeight: 100, alignment: .topLeading)
                        }
                    }

                    Spacer()

                    if !AIAnswer.isEmpty {
                        Text("Ai says: \n \(try! AttributedString(markdown: AIAnswer))")
                            .multilineTextAlignment(.leading)
                            .font(.subheadline)
                            .defaultScrollAnchor(.leading)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                AskAiView(UserQuestionSubmitted: $UserPrompt, Answer: $AIAnswer, ResultImageSubmitted: $ChatInputImage)
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

    @State private var ChosenImage: PhotosPickerItem? = nil
    @State private var ResultImage: Data = Data()
    @Binding var ResultImageSubmitted: Data

    var body: some View {
        VStack {
            if !ResultImage.isEmpty {
                VStack {
                    Text("Including image:").foregroundStyle(.gray).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    ScrollView(.horizontal) {
                        HStack {
                            Image(uiImage: UIImage(data: ResultImage)!)
                                .resizable()
                                .scaledToFit()

                        }.frame(maxWidth: .infinity, maxHeight: 100)
                    }
                }
            }
            HStack {
                PhotosPicker(selection: $ChosenImage) {
                    Image(systemName: "plus.square")
                }.buttonStyle(.bordered)
                    .onChange(of: ChosenImage) {
                        Task {
                            if let loaded = try? await ChosenImage?.loadTransferable(type: Data.self) {
                                ResultImage = loaded
                            } else {
                                print("Upload didn't work")
                            }
                        }
                    }
                TextField("Ask something", text: $UserQuestion, axis: .vertical)
                    .textFieldStyle(.roundedBorder).onKeyPress(.return, action: {
                        UserQuestionSubmitted = UserQuestion
                        UserQuestion = ""

                        ResultImageSubmitted = ResultImage
                        ResultImage = Data()
                        Task {
                            try await askAI(Question: UserQuestionSubmitted, Media: ResultImageSubmitted, Answer: Answer)
                        }
                        return .handled
                    })

                Button {
                    UserQuestionSubmitted = UserQuestion
                    UserQuestion = ""
                    Task {
                        try await askAI(Question: UserQuestionSubmitted, Media: ResultImageSubmitted, Answer: Answer)
                    }
                } label: {
                    Image(systemName: "paperplane")
                }.buttonStyle(.borderedProminent)

            }.padding(EdgeInsets(top: 0, leading: 2.5, bottom: 20, trailing: 2.5))

        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    func askAI(Question: String, Media: Data, Answer: String) async throws -> String {
        if !Media.isEmpty {
            let response = try await chat.sendMessage(Question, UIImage(data: Media)!)
            if let text = response.text {
                print(text)
                self.Answer = text
            }
        } else {
            let response = try await chat.sendMessage(Question)
            if let text = response.text {
                print(text)
                self.Answer = text
            }
        }
        return Answer
    }
}

struct AskingAIPreview: PreviewProvider {
    @State static var Question = "Hello, U up"
    @State static var Answer = "This is a test"

    @State static var ImageSub: Data = Data()
    // you know what f that including image. Data will be empty, add image in the preview yourself you lazy F

    static var previews: some View {
        AskAiView(UserQuestionSubmitted: $Question, Answer: $Answer, ResultImageSubmitted: $ImageSub)
    }
}
