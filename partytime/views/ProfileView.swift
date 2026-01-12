//
//  ProfileView.swift
//  partytime
//
//  Created by Curtis on 2025-10-09.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var hostViewModel = HostViewModel()
    @ObservedObject private var auth = authService.shared
    @State private var isEditing = false
    @State private var isLoading = true
    @State private var showingSaveSuccess = false
    @State private var showingBecomeHostAlert = false
    @State private var showingBecomeHostSuccess = false
    
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
                            if viewModel.profile?.isHost ?? false {
                                Text("Parties Hosted: \(hostViewModel.partyCount)")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if !(viewModel.profile?.isHost ?? false) {
                            Section {
                                Button(action: {
                                    showingBecomeHostAlert = true
                                }) {
                                    Text("Become a Host")
                                        .foregroundColor(.blue)
                                }
                            } footer: {
                                Text("Note: In the final product, you'll need to add banking information through Stripe and complete a KYU (Know Your User) verification process to become a host.")
                                    .font(.caption)
                            }
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
            .alert("Become a Host", isPresented: $showingBecomeHostAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Continue") {
                    Task {
                        do {
                            _ = try await hostViewModel.becomeHost()
                            showingBecomeHostSuccess = true
                            // Reload profile to get updated host status
                            _ = try await viewModel.getUserProfile()
                            _ = try await hostViewModel.getPartyCount()
                            // Notify that host status changed
                            NotificationCenter.default.post(name: NSNotification.Name("HostStatusChanged"), object: nil)
                        } catch {
                            print("Error becoming host: \(error)")
                        }
                    }
                }
            } message: {
                Text("In the final product, you'll need to complete Stripe onboarding and KYU verification. For now, this will instantly upgrade your account to host status.")
            }
            .alert("Profile Updated!", isPresented: $showingSaveSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your profile has been successfully updated.")
            }
            .alert("Welcome, Host!", isPresented: $showingBecomeHostSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You are now a host! New tabs will be available to manage your parties.")
            }
        }
    }
    
    private func loadProfile() {
        isLoading = true
        Task {
            do {
                _ = try await viewModel.getUserProfile()
                // If user is a host, get party count
                if viewModel.profile?.isHost ?? false {
                    _ = try await hostViewModel.getPartyCount()
                }
            } catch {
                print("Error loading profile: \(error)")
            }
            isLoading = false
        }
    }
}

