//
//  ContentView.swift
//  Jerma
//
//  Created by Patryk Puciłowski on 05/06/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
//            List {
//                ChatView()
//            }
        } detail: {
            ChatView()
        }
    }
}

#Preview {
    ContentView()
}
