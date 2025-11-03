//
//  Item.swift
//  turnie
//
//  Created by 坂村空介 on 2025/11/03.
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
