//
//  mainView.swift
//  partytime
//
//  Created by Curtis on 2025-07-27.
//

import SwiftUI

struct mainView: View {
    @ObservedObject var viewModel: LoginViewModel
    @ObservedObject private var auth = authService.shared
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var selectedTab = 0
    @State private var isHost = false
    @State private var isLoadingHostStatus = true
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Search/Discover Tab
            NavigationView {
                PartyFilterView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(0)
            
            // My Parties Tab (for all users - shows attended/pending parties)
            userParties()
                .tabItem {
                    Label("Parties", systemImage: "ticket")
                }
                .tag(1)
            
            // Parties Thrown Tab (for hosts only - shows parties they host)
            if isHost {
                HostMyPartiesView()
                    .tabItem {
                        Label("Thrown", systemImage: "house")
                    }
                    .tag(5)
            }
            
            // Create Party Tab (for hosts only)
            if isHost {
                CreatePartyView()
                    .tabItem {
                        Label("New Party", systemImage: "plus.circle")
                    }
                    .tag(4)
            }
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(3)
        }
        .onAppear {
            loadHostStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("HostStatusChanged"))) { _ in
            loadHostStatus()
        }
    }
    
    private func loadHostStatus() {
        isLoadingHostStatus = true
        Task {
            do {
                _ = try await profileViewModel.getUserProfile()
                isHost = profileViewModel.profile?.isHost ?? false
            } catch {
                print("Error loading host status: \(error)")
            }
            isLoadingHostStatus = false
        }
    }
}
