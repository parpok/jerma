//
//  BizLogic.swift
//  Jerma
//
//  Created by Patryk Puciłowski on 06/06/2024.
//

import Foundation
import GoogleGenerativeAI
import SwiftData

enum APIKey {
    // Fetch the API key from `GenerativeAI-Info.plist`
    static var `default`: String {
        guard let filePath = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist")
        else {
            fatalError("Couldn't find file 'GenerativeAI-Info.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
            fatalError("Couldn't find key 'API_KEY' in 'GenerativeAI-Info.plist'.")
        }
        if value.starts(with: "_") {
            fatalError(
                "Follow the instructions at https://ai.google.dev/tutorials/setup to get an API key."
            )
        }
        return value
    }
}

enum ModelsAvailble: String, CaseIterable, Identifiable {
    case gemini_1_5_flash = "gemini-1.5-flash"
    case gemini_1_5_pro = "gemini-1.5-pro"
    case gemini_1_pro = "gemini-1.0-pro"

    var id: Self {
        return self
    }
}

// The Gemini 1.5 models are versatile and work with both text-only and multimodal prompts
// Access your API key from your on-demand resource .plist file (see "Set up your API key" above)
let model = GenerativeModel(name: String(ModelsAvailble.gemini_1_5_flash.rawValue), apiKey: APIKey.default)
