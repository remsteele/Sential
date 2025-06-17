//
//  SentialApp.swift
//  Sential
//
//  Created by Remington Steele on 6/13/25.
//

import SwiftUI
import SwiftData

@main
struct SentialApp: App {
    @AppStorage("hasSeenLandingPage") private var hasSeenLandingPage = false
    
    var body: some Scene {
        WindowGroup {
            if hasSeenLandingPage {
                MainTabView()
            } else {
                LandingPage(onContinue: {
                    hasSeenLandingPage = true
                })
            }
        }
        .modelContainer(for: [UserSettings.self, FoodIntake.self, ChatMessage.self])
    }
}
