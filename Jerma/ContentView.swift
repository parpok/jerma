//
//  ContentView.swift
//  Jerma
//
//  Created by Patryk Puciłowski on 05/06/2024.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Query private var Chats: [Chats]
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
}

#Preview {
    ContentView()
        .modelContainer(for: Chats.self, inMemory: true)
}
