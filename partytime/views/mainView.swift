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
    @State private var selectedTab = 0
    
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
            
            // Active Parties Tab
            ActivePartiesView()
                .tabItem {
                    Label("My Parties", systemImage: "ticket")
                }
                .tag(1)
            
            // Saved Parties Tab
            SavedPartiesView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark")
                }
                .tag(2)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(3)
        }
    }
}
