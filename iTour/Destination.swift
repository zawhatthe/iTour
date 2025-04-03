//
//  Destination.swift
//  iTour
//
//  Created by Jonathan Zawada on 1/4/2025.
//

import Foundation
import SwiftData

@Model
class Destination {
    var name: String
    var details: String
    var date: Date
    var priority: Int
    var rank: Int
    @Relationship(deleteRule: .cascade) var sights = [Sight]()
    
    init(name: String = "", details: String = "", date: Date = .now, priority: Int = 2, rank: Int = 0) {
        self.name = name
        self.details = details
        self.date = date
        self.priority = priority
        self.rank = rank
    }
}
