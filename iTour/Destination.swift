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
    var rank: Int
    @Relationship(deleteRule: .cascade) var sights = [Sight]()
    
    init(name: String = "", details: String = "", rank: Int = -1) {
        self.name = name
        self.details = details
        self.rank = rank
    }
}
