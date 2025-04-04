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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Destination.self, Category.self, Sight.self])
    }
}
