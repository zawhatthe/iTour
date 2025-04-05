//
//  ProfileView.swift
//  iTour
//
//  Created by Jonathan Zawada on 4/5/2025.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Bindable var user: User
    @State private var isEditing = false
    @State private var editedUsername: String = ""
    @State private var editedBio: String = ""
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.modelContext) var modelContext
    
    @Query var publicDestinations: [Destination]
    
    var isCurrentUser: Bool {
        user.id == authManager.currentUser?.id
    }
    
    init(user: User) {
        self.user = user
        
        // Query for public destinations created by this user
        let predicate = #Predicate<Destination> {
            $0.creator?.id == user.id && $0.isPublic == true
        }
        
        _publicDestinations = Query(predicate: predicate, sort: [SortDescriptor(\Destination.name)])
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    profileHeader
                    
                    Divider()
                    
                    userStats
                        .padding(.vertical)
                    
                    if isEditing {
                        editProfileSection
                    } else {
                        aboutSection
                    }
                    
                    Divider()
                    
                    publicItemsSection
                }
                .padding()
            }
            .navigationTitle(isCurrentUser ? "My Profile" : user.username)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isCurrentUser {
                        Button(isEditing ? "Done" : "Edit") {
                            if isEditing {
                                saveProfile()
                            } else {
                                startEditing()
                            }
                            isEditing.toggle()
                        }
                    } else {
                        followButton
                    }
                }
                
                if isCurrentUser {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Sign Out") {
                            authManager.logout()
                        }
                    }
                }
            }
        }
    }
    
    private var profileHeader: some View {
        HStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.username)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var userStats: some View {
        HStack(spacing: 40) {
            VStack {
                Text("\(publicDestinations.count)")
                    .font(.headline)
                Text("Items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            NavigationLink(destination: UserListView(users: user.followers, title: "Followers")) {
                VStack {
                    Text("\(user.followers.count)")
                        .font(.headline)
                    Text("Followers")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            NavigationLink(destination: UserListView(users: user.following, title: "Following")) {
                VStack {
                    Text("\(user.following.count)")
                        .font(.headline)
                    Text("Following")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.headline)
            
            Text(user.bio.isEmpty ? "No bio yet" : user.bio)
                .font(.body)
                .foregroundColor(user.bio.isEmpty ? .secondary : .primary)
        }
    }
    
    private var editProfileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Edit Profile")
                .font(.headline)
            
            TextField("Username", text: $editedUsername)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            TextField("Bio", text: $editedBio, axis: .vertical)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .frame(minHeight: 100)
        }
    }
    
    private var publicItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Public Items")
                .font(.headline)
            
            if publicDestinations.isEmpty {
                Text("No public items yet")
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(publicDestinations) { destination in
                        NavigationLink(destination: DestinationDetailView(destination: destination)) {
                            destinationCard(for: destination)
                        }
                    }
                }
            }
        }
    }
    
    private func destinationCard(for destination: Destination) -> some View {
        VStack(alignment: .leading) {
            Text(destination.name)
                .font(.headline)
                .lineLimit(1)
            
            Text(destination.category?.name ?? "Uncategorized")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            HStack {
                Text(String(destination.rank))
                    .font(.caption2)
                    .padding(6)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
            }
        }
        .padding()
        .frame(height: 120)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var followButton: some View {
        Button(isFollowing ? "Unfollow" : "Follow") {
            if isFollowing {
                authManager.unfollowUser(user)
            } else {
                authManager.followUser(user)
            }
        }
        .buttonStyle(.borderedProminent)
    }
    
    private var isFollowing: Bool {
        guard let currentUser = authManager.currentUser else { return false }
        return currentUser.following.contains { $0.id == user.id }
    }
    
    private func startEditing() {
        editedUsername = user.username
        editedBio = user.bio
    }
    
    private func saveProfile() {
        authManager.updateProfile(
            username: editedUsername,
            bio: editedBio,
            profileImageName: user.profileImageName
        )
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, configurations: config)
        let example = User(username: "johnsmith", email: "john@example.com", bio: "I love traveling and exploring new places.")
        return ProfileView(user: example)
            .modelContainer(container)
            .environmentObject(AuthManager())
    } catch {
        fatalError("Failed to create model container.")
    }
}
