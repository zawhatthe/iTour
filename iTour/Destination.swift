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

    // Static names of predefined categories - not the actual objects
    static let predefinedCategories = [
        "Book",
        "Music",
        "Film",
        "TV Show",
        "Video Game",
        "Podcast",
        "Artist"
    ]
    
    // Fetch or create categories from the database
    static func getAllCategories(modelContext: ModelContext) -> [Category] {
        do {
            // Try to fetch existing categories
            let descriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.name)])
            let existingCategories = try modelContext.fetch(descriptor)
            
            // If we have all our categories already, return them
            if existingCategories.count >= predefinedCategories.count {
                return existingCategories
            }
            
            // Otherwise, create missing categories
            var categories: [Category] = []
            
            for categoryName in predefinedCategories {
                // Check if this category already exists
                let fetchDescriptor = FetchDescriptor<Category>(
                    predicate: #Predicate { $0.name == categoryName }
                )
                
                let existing = try modelContext.fetch(fetchDescriptor)
                
                if let existingCategory = existing.first {
                    categories.append(existingCategory)
                } else {
                    // Create new category if it doesn't exist
                    let newCategory = Category(name: categoryName)
                    modelContext.insert(newCategory)
                    categories.append(newCategory)
                }
            }
            
            return categories
        } catch {
            print("Error fetching or creating categories: \(error)")
            return []
        }
    }
}

@Model
class Destination {
    var name: String
    var details: String
    var rank: Int
    @Attribute(.unique) var id: UUID = UUID()
    
    // One-to-one relationship with Category
    @Relationship var cat: Category?
    
    @Relationship(deleteRule: .cascade) var sights = [Sight]()
    
    init(name: String = "", details: String = "", rank: Int = -1, cat: Category? = nil) {
        self.name = name
        self.details = details
        self.rank = rank
        self.cat = cat
    }
}
