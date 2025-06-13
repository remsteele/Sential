//
//  MainTabView.swift
//  Sential
//
//  Created by Remington Steele on 6/13/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message")
                }
            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
