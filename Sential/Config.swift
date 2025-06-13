//
//  Config.swift
//  Sential
//
//  Created by Remington Steele on 6/13/25.
//

import Foundation

struct Config {
    static var openAIAPIKey: String {
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String {
            return apiKey
        } else {
            print("OPENAI_API_KEY not found in Info.plist")
            return ""
        }
    }
}

