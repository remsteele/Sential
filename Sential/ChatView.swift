//
//  ChatView.swift
//  Sential
//
//  Created by Remington Steele on 6/13/25.
//

import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var messages: [Message] = []
    @State private var inputText = ""
    
    let apiKey = Config.openAIAPIKey
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(messages) { message in
                        Text(message.content)
                            .padding()
                            .background(message.role == "user" ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
            }
            HStack {
                TextField("Type a message", text: $inputText)
                Button("Send") {
                    sendMessage()
                }
            }
            .padding()
        }
    }
    
    private func sendMessage() {
        let userMessage = Message(role: "user", content: inputText)
        messages.append(userMessage)
        inputText = ""
        Task {
            await processMessage(userMessage)
        }
    }
    
    private func processMessage(_ message: Message) async {
        var currentMessages = messages
        let systemMessage = Message(role: "system", content: getSystemMessage())
        currentMessages.insert(systemMessage, at: 0)
        
        let functions: [[String: Any]] = [
            [
                "name": "log_food",
                "description": "Log a food intake",
                "parameters": [
                    "type": "object",
                    "properties": [
                        "food_name": ["type": "string"],
                        "calories": ["type": "integer"],
                        "protein": ["type": "integer", "optional": true],
                        "fat": ["type": "integer", "optional": true],
                        "carbs": ["type": "integer", "optional": true]
                    ]
                ]
            ],
            [
                "name": "get_remaining_calories",
                "description": "Get remaining calories for the day",
                "parameters": ["type": "object", "properties": [:]]
            ]
        ]
        
        while true {
            guard let response = await sendToAPI(messages: currentMessages, functions: functions) else { break }
            if let content = response.text {
                let assistantMessage = Message(role: "assistant", content: content)
                messages.append(assistantMessage)
                break
            } else if let (name, arguments) = response.functionCall {
                let result = executeFunction(name: name, arguments: arguments)
                let functionResponse = Message(role: "function", content: result, name: name)
                currentMessages.append(functionResponse)
            }
        }
    }
    
    private func getSystemMessage() -> String {
        if let settings = try? modelContext.fetch(FetchDescriptor<UserSettings>()).first {
            var message = "You are a helpful assistant for tracking calorie intake."
            if let goal = settings.goal { message += " The user's goal is to \(goal.rawValue)." }
            if let calorieTarget = settings.calorieTarget { message += " Their calorie target is \(calorieTarget)." }
            if settings.trackProtein, let proteinTarget = settings.proteinTarget { message += " Track protein: \(proteinTarget)g." }
            if settings.trackFat, let fatTarget = settings.fatTarget { message += " Track fat: \(fatTarget)g." }
            if settings.trackCarbs, let carbTarget = settings.carbTarget { message += " Track carbs: \(carbTarget)g." }
            return message
        }
        return "You are a helpful assistant for tracking calorie intake."
    }
    
    private func sendToAPI(messages: [Message], functions: [[String: Any]]) async -> APIResponse? {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        print("Bearer \(apiKey)")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages.map { ["role": $0.role, "content": $0.content, "name": $0.name].compactMapValues { $0 } },
            "functions": functions
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
            let choice = (json["choices"] as! [[String: Any]]).first!
            let message = choice["message"] as! [String: Any]
            if let content = message["content"] as? String {
                return APIResponse(text: content, functionCall: nil)
            } else if let functionCall = message["function_call"] as? [String: Any],
                      let name = functionCall["name"] as? String,
                      let argsString = functionCall["arguments"] as? String,
                      let argsData = argsString.data(using: .utf8),
                      let args = try? JSONSerialization.jsonObject(with: argsData) as? [String: Any] {
                return APIResponse(text: nil, functionCall: (name, args))
            }
            return nil
        } catch {
            print("API Error: \(error)")
            return nil
        }
    }
    
    private func executeFunction(name: String, arguments: [String: Any]) -> String {
        switch name {
        case "log_food":
            let foodName = arguments["food_name"] as! String
            let calories = arguments["calories"] as! Int
            let protein = arguments["protein"] as? Int
            let fat = arguments["fat"] as? Int
            let carbs = arguments["carbs"] as? Int
            let food = FoodIntake(timestamp: Date(), foodName: foodName, calories: calories, protein: protein, fat: fat, carbs: carbs)
            modelContext.insert(food)
            return "Food logged: \(foodName)"
        case "get_remaining_calories":
            let today = Calendar.current.startOfDay(for: Date())
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            let intakes = try! modelContext.fetch(FetchDescriptor<FoodIntake>(predicate: #Predicate { $0.timestamp >= today && $0.timestamp < endOfDay }))
            let total = intakes.reduce(0) { $0 + $1.calories }
            let target = (try? modelContext.fetch(FetchDescriptor<UserSettings>()).first?.calorieTarget) ?? 0
            return "\(target - total)"
        default:
            return "Unknown function"
        }
    }
}

struct Message: Identifiable {
    let id = UUID()
    let role: String
    let content: String
    let name: String?
    
    init(role: String, content: String, name: String? = nil) {
        self.role = role
        self.content = content
        self.name = name
    }
}

struct APIResponse {
    let text: String?
    let functionCall: (name: String, arguments: [String: Any])?
}
