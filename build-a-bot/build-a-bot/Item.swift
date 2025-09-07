//
//  Item.swift
//  build-a-bot
//
//  Created by Nikhil Sathyanarayana on 07/09/2025.
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
