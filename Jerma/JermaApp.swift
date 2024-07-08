//
//  JermaApp.swift
//  Jerma
//
//  Created by Patryk Puciłowski on 05/06/2024.
//

import SwiftUI
import SwiftData

@main
struct JermaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(for: Chat.self, isAutosaveEnabled: true)
    }
}
