//
//  RootView.swift
//  iTour
//
//  Created by Jonathan Zawada on 4/5/2025.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                TabView {
                    ContentView()
                        .tabItem {
                            Label("Pentangle", systemImage: "list.star")
                        }
                    
                    ExploreView()
                        .tabItem {
                            Label("Explore", systemImage: "globe")
                        }
                    
                    ProfileView(user: authManager.currentUser!)
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                }
            } else {
                AuthView()
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AuthManager())
}
