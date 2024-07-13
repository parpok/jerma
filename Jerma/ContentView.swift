//
//  ContentView.swift
//  Jerma
//
//  Created by Patryk Puciłowski on 05/06/2024.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Query private var Chats: [Chat]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationSplitView {
            List {
                Section {
                    NavigationLink("New Chat", destination: ChatView())
                }
                Section("Previous chats") {
                    ForEach(Chats) { chat in
                        NavigationLink(destination: ChatView(ChatsArray: chat.chatHistory), label: {
                            Text("Chat from \(chat.date)")
                        })
                            .swipeActions {
                                Button("Delete chat", systemImage: "trash", role: .destructive) {
                                    modelContext.delete(chat)
                                }
                            }
                    }
                }
            }.navigationTitle("Germa")

        } detail: {
            ChatView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Chat.self, inMemory: true)
}
