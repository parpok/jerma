//
//  chat.swift
//  Jerma
//
//  Created by Patryk Puciłowski on 13/07/2024.
//

import SwiftUI

struct AskAiView: View {
    @State private var UserQuestion: String = ""
    @State private var UserQuestionSubmitted: String = ""
    @State private var Answer: String = ""
    @Environment(\.modelContext) private var ModelContext
    @Binding var chatArray: [[Role: String]]
    @State var CurrentChat: Chat?

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
        if let currentChat = CurrentChat {
            currentChat.chatHistory = chatArray
        } else {
            CurrentChat = Chat(ChatID: UUID(), date: Date.now, chatHistory: chatArray)
            ModelContext.insert(CurrentChat!)
        }

        do {
            try ModelContext.save()
        } catch {
            print(error)
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
