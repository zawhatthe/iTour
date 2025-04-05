//
//  UserListView.swift
//  iTour
//
//  Created by Jonathan Zawada on 4/5/2025.
//

import SwiftUI

struct UserListView: View {
    let users: [User]
    let title: String
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        List {
            ForEach(users) { user in
                NavigationLink(destination: ProfileView(user: user)) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.username)
                                .font(.headline)
                            
                            Text(user.bio.isEmpty ? "No bio" : user.bio)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
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
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(title)
    }
    
    private func isFollowing(_ user: User) -> Bool {
        guard let currentUser = authManager.currentUser else { return false }
        return currentUser.following.contains { $0.id == user.id }
    }
}

#Preview {
    NavigationStack {
        UserListView(
            users: [
                User(username: "user1", email: "user1@example.com", bio: "Bio for user 1"),
                User(username: "user2", email: "user2@example.com", bio: "Bio for user 2"),
                User(username: "user3", email: "user3@example.com", bio: "Bio for user 3")
            ],
            title: "Followers"
        )
        .environmentObject(AuthManager())
    }
}
