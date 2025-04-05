//
//  ExploreView.swift
//  iTour
//
//  Created by Jonathan Zawada on 4/5/2025.
//

import SwiftUI
import SwiftData

struct ExploreView: View {
    @Query(filter: #Predicate<Destination> { $0.isPublic == true },
           sort: [SortDescriptor(\Destination.name)]) var publicDestinations: [Destination]
    
    @Query var allUsers: [User]
    @State private var searchText = ""
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Featured Users
                    featuredUsersSection
                    
                    Divider()
                    
                    // Public Items
                    publicItemsSection
                }
                .padding()
            }
            .navigationTitle("Explore")
            .searchable(text: $searchText, prompt: "Search users or items")
        }
    }
    
    private var featuredUsersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("People to Follow")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(filteredUsers) { user in
                        NavigationLink(destination: ProfileView(user: user)) {
                            VStack {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.blue)
                                
                                Text(user.username)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                if user.id != authManager.currentUser?.id {
                                    Button(isFollowing(user) ? "Unfollow" : "Follow") {
                                        if isFollowing(user) {
                                            authManager.unfollowUser(user)
                                        } else {
                                            authManager.followUser(user)
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.mini)
                                    .padding(.top, 4)
                                }
                            }
                            .frame(width: 100)
                            .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var publicItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Discover New Items")
                .font(.headline)
            
            if filteredDestinations.isEmpty {
                Text("No public items found")
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(filteredDestinations) { destination in
                        NavigationLink(destination: DestinationDetailView(destination: destination)) {
                            VStack(alignment: .leading) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading) {
                                        Text(destination.name)
                                            .font(.headline)
                                            .lineLimit(1)
                                        
                                        Text(destination.category?.name ?? "Uncategorized")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(String(destination.rank))
                                        .font(.caption)
                                        .padding(6)
                                        .background(Color.blue.opacity(0.2))
