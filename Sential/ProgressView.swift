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
    @Query private var foodIntakes: [FoodIntake]
    @State private var selectedFood: FoodIntake? = nil
    
    var body: some View {
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let foodIntakesForDay = foodIntakes.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }
        let groupedFoodIntakes = Dictionary(grouping: foodIntakesForDay) { (food: FoodIntake) -> String in
            let hour = Calendar.current.component(.hour, from: food.timestamp)
            if hour < 12 { return "Morning" }
            else if hour < 18 { return "Afternoon" }
            else { return "Evening" }
        }
        
        VStack {
            HStack {
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)!
                }) {
                    Image(systemName: "chevron.left")
                }
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .labelsHidden()
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)!
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            List {
                ForEach(["Morning", "Afternoon", "Evening"], id: \.self) { period in
                    if let foods = groupedFoodIntakes[period]?.sorted(by: { $0.timestamp < $1.timestamp }), !foods.isEmpty {
                        Section(header: Text(period)) {
                            ForEach(foods) { food in
                                Button(action: {
                                    selectedFood = food
                                }) {
                                    HStack {
                                        Text(food.foodName)
                                        Spacer()
                                        Text("\(food.calories) cal")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if let settings = try? modelContext.fetch(FetchDescriptor<UserSettings>()).first {
                let totalCalories = foodIntakesForDay.reduce(0) { $0 + $1.calories }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Calories: \(totalCalories) / \(settings.calorieTarget ?? 0) cal")
                        .font(.headline)
                        .foregroundColor(.primary)
                    if settings.trackProtein {
                        let totalProtein = foodIntakesForDay.compactMap { $0.protein }.reduce(0, +)
                        Text("Total Protein: \(totalProtein) / \(settings.proteinTarget ?? 0) g")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    if settings.trackFat {
                        let totalFat = foodIntakesForDay.compactMap { $0.fat }.reduce(0, +)
                        Text("Total Fat: \(totalFat) / \(settings.fatTarget ?? 0) g")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    if settings.trackCarbs {
                        let totalCarbs = foodIntakesForDay.compactMap { $0.carbs }.reduce(0, +)
                        Text("Total Carbs: \(totalCarbs) / \(settings.carbTarget ?? 0) g")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
        .sheet(item: $selectedFood) { food in
            VStack {
                Text(food.foodName)
                    .font(.headline)
                Text("Calories: \(food.calories) cal")
                if let protein = food.protein {
                    Text("Protein: \(protein) g")
                }
                if let fat = food.fat {
                    Text("Fat: \(fat) g")
                }
                if let carbs = food.carbs {
                    Text("Carbs: \(carbs) g")
                }
                Button("Close") {
                    selectedFood = nil
                }
            }
            .padding()
        }
    }
}
