//
//  Models.swift
//  Sential
//
//  Created by Remington Steele on 6/13/25.
//

import Foundation
import SwiftData

enum GoalType: String, Codable {
    case loseWeight
    case gainMuscle
    case maintain
}

@Model
class UserSettings {
    var goal: GoalType?
    var calorieTarget: Int?
    var trackProtein: Bool = false
    var proteinTarget: Int?
    var trackFat: Bool = false
    var fatTarget: Int?
    var trackCarbs: Bool = false
    var carbTarget: Int?
    
    init() {}
}

@Model
class FoodIntake {
    var timestamp: Date
    var foodName: String
    var calories: Int
    var protein: Int?
    var fat: Int?
    var carbs: Int?
    
    init(timestamp: Date, foodName: String, calories: Int, protein: Int? = nil, fat: Int? = nil, carbs: Int? = nil) {
        self.timestamp = timestamp
        self.foodName = foodName
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbs = carbs
    }
}

@Model
class ChatMessage {
    var timestamp: Date
    var role: String
    var content: String
    var name: String?
    
    init(timestamp: Date, role: String, content: String, name: String? = nil) {
        self.timestamp = timestamp
        self.role = role
        self.content = content
        self.name = name
    }
}
