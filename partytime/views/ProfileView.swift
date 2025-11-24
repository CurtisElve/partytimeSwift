//
//  ProfileView.swift
//  partytime
//
//  Created by Curtis on 2025-10-09.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @ObservedObject private var auth = authService.shared
    @State private var isEditing = false
    @State private var isLoading = true
    @State private var showingSaveSuccess = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Form {
                        Section("Profile Information") {
                            TextField("Username", text: $viewModel.username)
                                .disabled(!isEditing)
                            TextField("Phone", text: $viewModel.phone)
                                .disabled(!isEditing)
                            TextField("Bio", text: $viewModel.bio, axis: .vertical)
                                .lineLimit(3...6)
                                .disabled(!isEditing)
                            TextField("Profile Picture URL", text: $viewModel.pfpURL)
                                .disabled(!isEditing)
                        }
                        
                        Section("Account") {
                            if let email = viewModel.profile?.email {
                                Text("Email: \(email)")
                                    .foregroundColor(.secondary)
                            }
                            Text("Host Status: \(viewModel.profile?.isHost ?? false ? "Yes" : "No")")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if isEditing {
                        Button(action: {
                            Task {
                                do {
                                    _ = try await viewModel.updateProfile()
                                    isEditing = false
                                    showingSaveSuccess = true
                                } catch {
                                    print("Error updating profile: \(error)")
                                }
                            }
                        }) {
                            Text("Save Changes")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if !isEditing {
                        Button("Edit") {
                            isEditing = true
                        }
                        Button("Logout") {
                            auth.logout { success, error in
                                if let error = error {
                                    print("Error logging out: \(error)")
                                }
                            }
                        }
                    } else {
                        Button("Cancel") {
                            // Reset to original values
                            if let profile = viewModel.profile {
                                viewModel.username = profile.username
                                viewModel.phone = profile.phone ?? ""
                                viewModel.bio = profile.bio ?? ""
                                viewModel.pfpURL = profile.pfpURL ?? ""
                            }
                            isEditing = false
                        }
                    }
                }
            }
            .onAppear {
                loadProfile()
            }
            .alert("Profile Updated!", isPresented: $showingSaveSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your profile has been successfully updated.")
            }
        }
    }
    
    private func loadProfile() {
        isLoading = true
        Task {
            do {
                _ = try await viewModel.getUserProfile()
            } catch {
                print("Error loading profile: \(error)")
            }
            isLoading = false
        }
    }
}

