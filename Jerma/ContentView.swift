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
                    ForEach(Chats) { _ in
                        NavigationLink("Chat", destination: ChatView())
                    }
                }
            }.navigationTitle("Germa")

        } detail: {
            ChatView()
        }
    }

    func deletething(_ indexSet: IndexSet) {
        for i in indexSet {
            let chats = Chats[i]
            modelContext.delete(chats)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Chat.self, inMemory: true)
}
