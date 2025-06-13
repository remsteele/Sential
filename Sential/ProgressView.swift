//
//  ProgressView.swift
//  Sential
//
//  Created by Remington Steele on 6/13/25.
//

import SwiftUI
import SwiftData

struct ProgressView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedDate = Date()
    @Query private var foodIntakes: [FoodIntake] // Moved to struct level
    
    var body: some View {
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        // @Query filter is now applied here dynamically
        VStack {
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .padding()
            List(foodIntakes.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }) { food in
                HStack {
                    Text(food.foodName)
                    Spacer()
                    Text("\(food.calories) cal")
                }
            }
            if let settings = try? modelContext.fetch(FetchDescriptor<UserSettings>()).first {
                let totalCalories = foodIntakes.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }.reduce(0) { $0 + $1.calories }
                Text("Total Calories: \(totalCalories) / \(settings.calorieTarget ?? 0) cal")
                if settings.trackProtein {
                    let totalProtein = foodIntakes.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }.compactMap { $0.protein }.reduce(0, +)
                    Text("Total Protein: \(totalProtein) / \(settings.proteinTarget ?? 0) g")
                }
                if settings.trackFat {
                    let totalFat = foodIntakes.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }.compactMap { $0.fat }.reduce(0, +)
                    Text("Total Fat: \(totalFat) / \(settings.fatTarget ?? 0) g")
                }
                if settings.trackCarbs {
                    let totalCarbs = foodIntakes.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }.compactMap { $0.carbs }.reduce(0, +)
                    Text("Total Carbs: \(totalCarbs) / \(settings.carbTarget ?? 0) g")
                }
            }
        }
    }
}
