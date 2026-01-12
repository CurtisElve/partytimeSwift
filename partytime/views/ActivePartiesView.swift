//
//  ActivePartiesView.swift
//  partytime
//
//  Created by Curtis on 2025-10-09.
//

import SwiftUI

struct ActivePartiesView: View {
    @StateObject private var viewModel = ActivePartiesViewModel()
    @State private var pendingParties: [api.partyWithRequest] = []
    @State private var acceptedParties: [api.partyWithRequest] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if pendingParties.isEmpty && acceptedParties.isEmpty {
                    VStack {
                        Text("No active parties")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Buy tickets to parties to see them here!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        // Accepted Parties Section
                        if !acceptedParties.isEmpty {
                            Section("Accepted") {
                                ForEach(acceptedParties) { party in
                                    NavigationLink(destination: TicketView(party: party)) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(party.name)
                                                .font(.headline)
                                            if let hashtags = party.hashtags {
                                                Text(hashtags)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            Text("Ticket confirmed ✓")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Pending Parties Section
                        if !pendingParties.isEmpty {
                            Section("Pending Approval") {
                                ForEach(pendingParties) { party in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(party.name)
                                            .font(.headline)
                                        if let hashtags = party.hashtags {
                                            Text(hashtags)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Text("Waiting for host approval...")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                loadActiveParties()
            }
            .refreshable {
                loadActiveParties()
            }
        }
    }
    
    private func loadActiveParties() {
        isLoading = true
        Task {
            do {
                let activeParties = try await viewModel.getActiveParties()
                pendingParties = activeParties.pending_parties
                acceptedParties = activeParties.accepted_parties
            } catch {
                print("Error loading active parties: \(error)")
            }
            isLoading = false
        }
    }
}

