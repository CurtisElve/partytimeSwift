//
//  singleParty.swift
//  partytime
//
//  Created by Curtis on 2025-10-09.
//

import SwiftUI

struct singleParty: View {
    let party: api.baseParty
    @StateObject private var viewModel = PartyDetailsViewModel()
    @State private var partyDetails: api.partyDetails?
    @State private var isLoading = true
    @State private var showingPayment = false
    
    init(party: api.baseParty) {
        self.party = party
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if let details = partyDetails {
                    // Party header
                    Text(details.name)
                        .font(.largeTitle)
                        .bold()
                    
                    if let description = details.description {
                        Text(description)
                            .font(.body)
                    }
                    
                    // Host info
                    if let host = details.host {
                        Text("Host: \(host.username)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Party details
                    VStack(alignment: .leading, spacing: 8) {
                        if let startTime = details.start_time {
                            Text("Start: \(formatDate(startTime))")
                        }
                        if let endTime = details.end_time {
                            Text("End: \(formatDate(endTime))")
                        }
                        Text("Attendees: \(details.attendee_count)/\(details.max_attendees)")
                        if let address = details.address {
                            Text("Location: \(address)")
                        }
                        if let hashtags = details.hashtags {
                            Text("Tags: \(hashtags)")
                        }
                    }
                    .font(.subheadline)
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        // Save/Unsave button
                        Button(action: {
                            Task {
                                if details.is_saved {
                                    _ = try? await viewModel.unsaveParty(partyId: details.id)
                                } else {
                                    _ = try? await viewModel.saveParty(partyId: details.id)
                                }
                            }
                        }) {
                            Image(systemName: details.is_saved ? "bookmark.fill" : "bookmark")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        // Buy ticket button
                        if !details.has_request {
                            Button(action: {
                                showingPayment = true
                            }) {
                                Text("Buy Ticket")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        } else if details.request_accepted {
                            Text("Ticket Purchased ✓")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        } else {
                            Text("Pending Approval")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                } else {
                    Text("Failed to load party details")
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
        .navigationTitle("Party Details")
        .onAppear {
            Task {
                do {
                    partyDetails = try await viewModel.getPartyDetails(partyId: party.id)
                    isLoading = false
                } catch {
                    isLoading = false
                }
            }
        }
        .sheet(isPresented: $showingPayment) {
            PaymentView(partyId: party.id, viewModel: viewModel)
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
