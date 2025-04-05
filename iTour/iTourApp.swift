//
//  iTourApp.swift
//  iTour
//
//  Created by Jonathan Zawada on 1/4/2025.
//

import SwiftUI
import SwiftData

@main
struct iTourApp: App {
    @State private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
        }
        .modelContainer(for: [User.self, Destination.self, Category.self, Sight.self]) { container in
            // Initialize authManager with the model context
            let context = container.mainContext
            authManager.initialize(with: context)
        }
    }
}
