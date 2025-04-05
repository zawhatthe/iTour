//
//  Destination.swift
//  iTour
//
//  Created by Jonathan Zawada on 1/4/2025.
//

import Foundation
import SwiftData

@Model
class Category {
    @Attribute(.unique) var id: UUID = UUID()  // Unique identifier
    var name: String

    init(name: String) {
        self.name = name
    }

    // Static list of predefined categories
    static let allCategories: [Category] = [
        Category(name: "Book"),
        Category(name: "Music"),
        Category(name: "Film"),
        Category(name: "TV Show"),
        Category(name: "Video Game"),
        Category(name: "Podcast"),
        Category(name: "Artist")
    ]
}

@Model
class Destination {
    var name: String
    var details: String
    var rank: Int
    @Attribute(.unique) var id: UUID = UUID()
    var isPublic: Bool = false // Whether this destination is visible to other users
    
    // One-to-one relationship with Category
    @Relationship var category: Category?
    
    // Relationship to the user who created this destination
    @Relationship var creator: User?
    
    @Relationship(deleteRule: .cascade) var sights = [Sight]()
    
    init(name: String = "", details: String = "", rank: Int = -1, category: Category? = nil, creator: User? = nil, isPublic: Bool = false) {
        self.name = name
        self.details = details
        self.rank = rank
        self.category = category
        self.creator = creator
        self.isPublic = isPublic
    }
}
