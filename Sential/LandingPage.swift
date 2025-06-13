//
//  LandingPage.swift
//  Sential
//
//  Created by Remington Steele on 6/13/25.
//

import SwiftUI

struct LandingPage: View {
    var onContinue: () -> Void
    
    var body: some View {
        VStack {
            Text("Welcome to Sential")
                .font(.largeTitle)
            Text("Track your calorie intake with an AI assistant to achieve your health goals.")
                .multilineTextAlignment(.center)
                .padding()
            Button("Continue") {
                onContinue()
            }
            .padding()
        }
    }
}
