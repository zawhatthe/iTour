//
//  User.swift
//  iTour
//
//  Created by Jonathan Zawada on 4/5/2025.
//

import Foundation
import SwiftData

@Model
class User {
    @Attribute(.unique) var id: UUID = UUID()
    var username: String
    var email: String
    var password: String // In a real app, you would store a hashed password
    var profileImageName: String?
    var bio: String
    
    // Relationship to destinations created by this user
    @Relationship(deleteRule: .cascade, inverse: \Destination.creator) var destinations = [Destination]()
    
    // Users the current user is following
    @Relationship var following = [User]()
    
    // Users who follow the current user
    @Relationship(inverse: \User.following) var followers = [User]()
    
    init(username: String = "", email: String = "", password: String = "", profileImageName: String? = nil, bio: String = "") {
        self.username = username
        self.email = email
        self.password = password
        self.profileImageName = profileImageName
        self.bio = bio
    }
}
