//
//  ChatView.swift
//  Jerma
//
//  Created by Patryk Puciłowski on 07/06/2024.
//

import GoogleGenerativeAI
import PhotosUI
import SwiftUI

enum Role: String {
    case ai
    case user
}

struct ChatView: View {
    @State private var ChosenModel: ModelsAvailble = .gemini_1_5_flash

    private static var ChatDict: [Role: String] = [:]
    @State private var ChatsArray = [ChatDict]

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
//                    if !UserPrompt.isEmpty {
//                        Text("You: \n\(UserPrompt)")
//                            .multilineTextAlignment(.leading)
//                            .font(.subheadline)
//                            .defaultScrollAnchor(.leading)
//                            .frame(maxWidth: .infinity, alignment: .topLeading)
//                    }
//
//                    if !ChatInputImage.isEmpty {
//                        ScrollView(.horizontal) {
//                            HStack {
//                                Image(uiImage: UIImage(data: ChatInputImage)!)
//                                    .resizable()
//                                    .scaledToFit()
//
//                            }.frame(maxWidth: .infinity, maxHeight: 100, alignment: .topLeading)
//                        }
//                    }

                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                #if targetEnvironment(simulator)
                    .border(Color.blue)
                #endif

                AskAiView(chatArray: $ChatsArray)
//                AskAiView(UserQuestionSubmitted: $UserPrompt, Answer: $AIAnswer, ResultImageSubmitted: $ChatInputImage)
                #if targetEnvironment(simulator)
.border(Color.green)
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

struct AskAiView: View {
    @State private var UserQuestion: String = ""

    @Binding var chatArray: [[Role: String]]
    @State private var UserQuestionSubmitted: String = ""
    @State private var Answer: String = ""

    @State private var ChosenImage: PhotosPickerItem? = nil
    @State private var ResultImage: Data = Data()
//    @Binding var ResultImageSubmitted: Data

    var body: some View {
        VStack {
            if !ResultImage.isEmpty {
                VStack {
                    Text("Including image:").foregroundStyle(.gray).frame(maxWidth: .infinity, maxHeight: 100, alignment: .bottomLeading)
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
//                PhotosPicker(selection: $ChosenImage) {
//                    Image(systemName: "plus.square")
//                }.buttonStyle(.bordered)
//                    .onChange(of: ChosenImage) {
//                        Task {
//                            if let loaded = try? await ChosenImage?.loadTransferable(type: Data.self) {
//                                ResultImage = loaded
//                            } else {
//                                print("Upload didn't work")
//                            }
//                        }
//                    }
                TextField("Ask something", text: $UserQuestion, axis: .vertical)
                    .textFieldStyle(.roundedBorder).onKeyPress(.return, action: {
                        UserQuestionSubmitted = UserQuestion
                        chatArray.append([.user: UserQuestionSubmitted])
                        UserQuestion = ""

//                        ResultImageSubmitted = ResultImage
//                        ResultImage = Data()
                        Task {
                            try await askAI(Question: UserQuestionSubmitted, Answer: Answer)
                        }
                        return .handled
                    })

                Button {
                    UserQuestionSubmitted = UserQuestion
                    UserQuestion = ""
                    Task {
                        try await askAI(Question: UserQuestionSubmitted, Answer: Answer)
                    }
                } label: {
                    Image(systemName: "paperplane")
                }.buttonStyle(.borderedProminent)

            }.padding(EdgeInsets(top: 0, leading: 2.5, bottom: 20, trailing: 2.5))

        }.frame(maxWidth: .infinity, alignment: .bottom)
    }

    func askAI(Question: String, Answer: String) async throws {
        let response = try await chat.sendMessage(Question)
        if let text = response.text {
            print(text)
            self.Answer = text
            chatArray.append([.ai: text])
            // now better
        }
    }
}

struct AskingAIPreview: PreviewProvider {
    @State static var Chats: [[Role: String]] = [[.user: "Hello there"], [.ai: "whats up?"]]
    @State static var ImageSub: Data = Data()
    // you know what f that including image. Data will be empty, add image in the preview yourself you lazy F
    // Thats useless for now

    static var previews: some View {
        AskAiView(chatArray: $Chats)
    }
}
