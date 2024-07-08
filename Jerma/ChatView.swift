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

    @State private var ChatsArray: [[Role: String]] = []

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
                    .border(Color.blue)
                #endif

                AskAiView(chatArray: $ChatsArray)
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

    @State private var UserQuestionSubmitted: String = ""
    @State private var Answer: String = ""

    @Environment(\.modelContext) private var ModelContext

    @Binding var chatArray: [[Role: String]]
    var CurrentChat: Chat?
    var body: some View {
        VStack {
            HStack {
                TextField("Ask something", text: $UserQuestion, axis: .vertical)
                    .textFieldStyle(.roundedBorder).onKeyPress(.return, action: {
                        UserQuestionSubmitted = UserQuestion
                        chatArray.append([.user: UserQuestionSubmitted])
                        UserQuestion = ""

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
            save()
        }
    }

    private func save() {
        if var CurrentChat {
            CurrentChat.chatHistory = chatArray
        } else {
            let newChat = Chat(id: UUID(), chatHistory: chatArray)
            ModelContext.insert(newChat)
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
