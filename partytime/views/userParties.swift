//
//  UserPartiesView.swift
//  partytime
//
//  Created by Curtis on 2025-10-09.
//

import SwiftUI

struct userParties: View {
    // ViewModels
    @StateObject private var savedViewModel = SavedPartiesViewModel()
    @StateObject private var activeViewModel = ActivePartiesViewModel()
    
    // UI State
    @State private var selectedSegment = 0
    
    // Data State
    @State private var savedParties: [api.baseParty] = []
    @State private var pendingParties: [api.partyWithRequest] = []
    @State private var acceptedParties: [api.partyWithRequest] = []
    
    // Loading State
    @State private var isSavedLoading = true
    @State private var isActiveLoading = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Segmented Control to switch views
                Picker("View Mode", selection: $selectedSegment) {
                    Text("Going").tag(0)
                    Text("Saved").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content Switcher
                if selectedSegment == 0 {
                    activePartiesContent
                } else {
                    savedPartiesContent
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(selectedSegment == 0 ? "My Parties" : "Saved Parties")
            .onAppear {
                // Initial Load
                if selectedSegment == 0 { loadActiveParties() }
                else { loadSavedParties() }
            }
            .onAppear {
                loadActiveParties()
                loadSavedParties()
            }
            .refreshable {
                loadActiveParties()
                loadSavedParties()
            }
        }
    }
    
    // MARK: - Active Parties Content (Segment 0)
    var activePartiesContent: some View {
        Group {
            if isActiveLoading {
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
                .refreshable {
                    loadActiveParties()
                }
            }
        }
    }
    
    // MARK: - Saved Parties Content (Segment 1)
    var savedPartiesContent: some View {
        Group {
            if isSavedLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if savedParties.isEmpty {
                VStack {
                    Text("No saved parties yet")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("Save parties you're interested in!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(savedParties) { party in
                        NavigationLink(destination: singleParty(party: party)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(party.name)
                                    .font(.headline)
                                if let hashtags = party.hashtags {
                                    Text(hashtags)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Text("\(party.attendee_count)/\(party.max_attendees) attendees")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Task {
                                    _ = try? await savedViewModel.removeSavedParty(partyId: party.id)
                                    loadSavedParties()
                                }
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                }
                .refreshable {
                    loadSavedParties()
                }
            }
        }
    }
    
    // MARK: - Loading Functions
    private func loadActiveParties() {
        // Only show spinner if we have no data yet
        if pendingParties.isEmpty && acceptedParties.isEmpty { isActiveLoading = true }
        Task {
            do {
                let activeParties = try await activeViewModel.getActiveParties()
                pendingParties = activeParties.pending_parties
                acceptedParties = activeParties.accepted_parties
            } catch {
                print("Error loading active parties: \(error)")
            }
            isActiveLoading = false
        }
    }
    
    private func loadSavedParties() {
        // Only show spinner if we have no data yet
        if savedParties.isEmpty { isSavedLoading = true }
        Task {
            do {
                savedParties = try await savedViewModel.getSavedParties()
            } catch {
                print("Error loading saved parties: \(error)")
            }
            isSavedLoading = false
        }
    }
}
