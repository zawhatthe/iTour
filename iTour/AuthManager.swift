//
//  AuthManager.swift
//  iTour
//
//  Created by Jonathan Zawada on 4/5/2025.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class AuthManager {
    var currentUser: User?
    var isAuthenticated: Bool = false
    private var modelContext: ModelContext?
    
    func initialize(with modelContext: ModelContext) {
        self.modelContext = modelContext
        // Check if there's a saved user session
        loadSavedSession()
    }
    
    func register(username: String, email: String, password: String, bio: String) -> Bool {
        guard let modelContext = modelContext else { return false }
        
        // Check if username or email already exists
        let usernamePredicate = #Predicate<User> { $0.username == username }
        let emailPredicate = #Predicate<User> { $0.email == email }
        
        do {
            let existingUsername = try modelContext.fetch(FetchDescriptor<User>(predicate: usernamePredicate))
            if !existingUsername.isEmpty {
                return false // Username already exists
            }
            
            let existingEmail = try modelContext.fetch(FetchDescriptor<User>(predicate: emailPredicate))
            if !existingEmail.isEmpty {
                return false // Email already exists
            }
            
            // Create new user
            // In a real app, password should be hashed
            let newUser = User(username: username, email: email, password: password, bio: bio)
            modelContext.insert(newUser)
            
            // Log in the new user
            currentUser = newUser
            isAuthenticated = true
            saveSession()
            
            return true
        } catch {
            print("Registration error: \(error)")
            return false
        }
    }
    
    func login(email: String, password: String) -> Bool {
        guard let modelContext = modelContext else { return false }
        
        // In a real app, you would compare hashed passwords
        let predicate = #Predicate<User> { $0.email == email && $0.password == password }
        
        do {
            let users = try modelContext.fetch(FetchDescriptor<User>(predicate: predicate))
            
            if let user = users.first {
                currentUser = user
                isAuthenticated = true
                saveSession()
                return true
            } else {
                return false // Invalid credentials
            }
        } catch {
            print("Login error: \(error)")
            return false
        }
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        // Clear saved session
        UserDefaults.standard.removeObject(forKey: "savedUserID")
    }
    
    // Save current user session
    private func saveSession() {
        if let userId = currentUser?.id {
            UserDefaults.standard.set(userId.uuidString, forKey: "savedUserID")
        }
    }
    
    // Load saved user session
    private func loadSavedSession() {
        guard let modelContext = modelContext,
              let savedUserIdString = UserDefaults.standard.string(forKey: "savedUserID"),
              let savedUserId = UUID(uuidString: savedUserIdString) else {
            return
        }
        
        let predicate = #Predicate<User> { $0.id == savedUserId }
        
        do {
            let users = try modelContext.fetch(FetchDescriptor<User>(predicate: predicate))
            if let user = users.first {
                currentUser = user
                isAuthenticated = true
            }
        } catch {
            print("Failed to load saved user session: \(error)")
        }
    }
    
    func updateProfile(username: String, bio: String, profileImageName: String?) {
        guard let currentUser = currentUser else { return }
        
        currentUser.username = username
        currentUser.bio = bio
        currentUser.profileImageName = profileImageName
        
        saveSession()
    }
    
    func followUser(_ user: User) {
        guard let currentUser = currentUser, currentUser.id != user.id else { return }
        
        if !currentUser.following.contains(where: { $0.id == user.id }) {
            currentUser.following.append(user)
        }
    }
    
    func unfollowUser(_ user: User) {
        guard let currentUser = currentUser else { return }
        
        currentUser.following.removeAll(where: { $0.id == user.id })
    }
}
