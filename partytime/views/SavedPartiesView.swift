//
//  SavedPartiesView.swift
//  partytime
//
//  Created by Curtis on 2025-10-09.
//

import SwiftUI

struct SavedPartiesView: View {
    @StateObject private var viewModel = SavedPartiesViewModel()
    @State private var savedParties: [api.baseParty] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
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
                                        _ = try? await viewModel.removeSavedParty(partyId: party.id)
                                        loadSavedParties()
                                    }
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Saved Parties")
            .onAppear {
                loadSavedParties()
            }
            .refreshable {
                loadSavedParties()
            }
        }
    }
    
    private func loadSavedParties() {
        isLoading = true
        Task {
            do {
                savedParties = try await viewModel.getSavedParties()
            } catch {
                print("Error loading saved parties: \(error)")
            }
            isLoading = false
        }
    }
}

