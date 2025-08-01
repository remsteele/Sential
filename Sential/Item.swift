//
//  Item.swift
//  Sential
//
//  Created by Remington Steele on 6/13/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
