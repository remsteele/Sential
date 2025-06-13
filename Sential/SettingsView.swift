//
//  SettingsView.swift
//  Sential
//
//  Created by Remington Steele on 6/13/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [UserSettings]
    @Bindable private var settings: UserSettings
    
    init() {
        // Initialize with a default settings object
        _settings = Bindable(wrappedValue: UserSettings())
    }
    
    var body: some View {
        Form {
            Section(header: Text("Goal")) {
                Picker("Goal", selection: $settings.goal) {
                    Text("Lose Weight").tag(GoalType.loseWeight as GoalType?)
                    Text("Gain Muscle").tag(GoalType.gainMuscle as GoalType?)
                    Text("Maintain").tag(GoalType.maintain as GoalType?)
                }
            }
            Section(header: Text("Calorie Target")) {
                TextField("Calories", value: $settings.calorieTarget, format: .number)
                    .keyboardType(.numberPad)
            }
            Section(header: Text("Macros")) {
                Toggle("Track Protein", isOn: $settings.trackProtein)
                if settings.trackProtein {
                    TextField("Protein Target (g)", value: $settings.proteinTarget, format: .number)
                        .keyboardType(.numberPad)
                }
                Toggle("Track Fat", isOn: $settings.trackFat)
                if settings.trackFat {
                    TextField("Fat Target (g)", value: $settings.fatTarget, format: .number)
                        .keyboardType(.numberPad)
                }
                Toggle("Track Carbs", isOn: $settings.trackCarbs)
                if settings.trackCarbs {
                    TextField("Carbs Target (g)", value: $settings.carbTarget, format: .number)
                        .keyboardType(.numberPad)
                }
            }
        }
        .onAppear {
            // Check if settings exist; if not, insert the initialized settings
            if settingsList.isEmpty {
                modelContext.insert(settings)
            } else {
                // Copy values from the first existing settings object
                let existingSettings = settingsList[0]
                settings.goal = existingSettings.goal
                settings.calorieTarget = existingSettings.calorieTarget
                settings.trackProtein = existingSettings.trackProtein
                settings.proteinTarget = existingSettings.proteinTarget
                settings.trackFat = existingSettings.trackFat
                settings.fatTarget = existingSettings.fatTarget
                settings.trackCarbs = existingSettings.trackCarbs
                settings.carbTarget = existingSettings.carbTarget
            }
        }
    }
}
