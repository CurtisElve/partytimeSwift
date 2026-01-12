//
//  HostMyPartiesView.swift
//  partytime
//
//  Created by Curtis on 2025-10-09.
//

import SwiftUI

struct HostMyPartiesView: View {
    @StateObject private var viewModel = HostPartiesViewModel()
    @State private var activeParties: [api.hostParty] = []
    @State private var pastParties: [api.hostParty] = []
    @State private var futureParties: [api.hostParty] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if activeParties.isEmpty && pastParties.isEmpty && futureParties.isEmpty {
                    VStack {
                        Text("No parties yet")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Create your first party to get started!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        // Active Parties Section
                        if !activeParties.isEmpty {
                            Section("Active") {
                                ForEach(activeParties) { party in
                                    NavigationLink(destination: HostPartyDetailView(party: party)) {
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
                                }
                            }
                        }
                        
                        // Future Parties Section
                        if !futureParties.isEmpty {
                            Section("Upcoming") {
                                ForEach(futureParties) { party in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(party.name)
                                            .font(.headline)
                                        if let hashtags = party.hashtags {
                                            Text(hashtags)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        if let startTime = party.start_time {
                                            Text("Starts: \(formatDate(startTime))")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        
                        // Past Parties Section
                        if !pastParties.isEmpty {
                            Section("Past") {
                                ForEach(pastParties) { party in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(party.name)
                                            .font(.headline)
                                        if let hashtags = party.hashtags {
                                            Text(hashtags)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Text("Ended")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Parties Thrown")
            .onAppear {
                loadParties()
            }
            .refreshable {
                loadParties()
            }
        }
    }
    
    private func loadParties() {
        isLoading = true
        Task {
            do {
                let response = try await viewModel.getHostParties()
                activeParties = response.active_parties
                pastParties = response.past_parties
                futureParties = response.future_parties
            } catch {
                print("Error loading host parties: \(error)")
            }
            isLoading = false
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) ?? ISO8601DateFormatter().date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

