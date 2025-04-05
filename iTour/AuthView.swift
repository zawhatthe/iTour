//
//  AuthView.swift
//  iTour
//
//  Created by Jonathan Zawada on 4/5/2025.
//

import SwiftUI

struct AuthView: View {
    @State private var isShowingLogin = true
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var bio = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Pentangle")
                    .font(.system(size: 42, weight: .bold))
                    .padding(.bottom, 50)
                
                if isShowingLogin {
                    loginView
                } else {
                    registerView
                }
                
                Spacer()
                
                Button(isShowingLogin ? "Need an account? Register" : "Already have an account? Log in") {
                    isShowingLogin.toggle()
                    resetFields()
                }
                .padding()
            }
            .padding()
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var loginView: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            SecureField("Password", text: $password)
                .textContentType(.password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            Button("Log In") {
                handleLogin()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
    }
    
    private var registerView: some View {
        VStack(spacing: 20) {
            TextField("Username", text: $username)
                .textContentType(.username)
                .autocapitalization(.none)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            SecureField("Password", text: $password)
                .textContentType(.newPassword)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            TextField("Bio", text: $bio)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            Button("Register") {
                handleRegister()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
    }
    
    private func handleLogin() {
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        let success = authManager.login(email: email, password: password)
        if !success {
            errorMessage = "Invalid email or password"
            showError = true
        }
    }
    
    private func handleRegister() {
        if username.isEmpty || email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all required fields"
            showError = true
            return
        }
        
        let success = authManager.register(username: username, email: email, password: password, bio: bio)
        if !success {
            errorMessage = "Registration failed. Username or email may already be in use."
            showError = true
        }
    }
    
    private func resetFields() {
        email = ""
        username = ""
        password = ""
        bio = ""
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthManager())
}
