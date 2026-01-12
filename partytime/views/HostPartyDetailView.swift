//
//  HostPartyDetailView.swift
//  partytime
//
//  Created by Curtis on 2025-10-09.
//

import SwiftUI

struct HostPartyDetailView: View {
    let party: api.hostParty
    @StateObject private var viewModel = HostPartiesViewModel()
    @State private var requests: [api.partyRequest] = []
    @State private var attendees: [api.attendee] = []
    @State private var isLoading = true
    @State private var showingUserProfile: api.partyRequest? = nil
    @State private var showingAttendeeProfile: api.attendee? = nil
    
    var pendingRequests: [api.partyRequest] {
        requests.filter { !$0.accepted }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Party header
                Text(party.name)
                    .font(.largeTitle)
                    .bold()
                
                if let description = party.description {
                    Text(description)
                        .font(.body)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    if let startTime = party.start_time {
                        Text("Start: \(formatDate(startTime))")
                    }
                    if let endTime = party.end_time {
                        Text("End: \(formatDate(endTime))")
                    }
                    Text("Attendees: \(party.attendee_count)/\(party.max_attendees)")
                    if let address = party.address {
                        Text("Location: \(address)")
                    }
                    if let hashtags = party.hashtags {
                        Text("Tags: \(hashtags)")
                    }
                }
                .font(.subheadline)
                
                Divider()
                
                // Guestlist Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Guestlist (\(attendees.count))")
                        .font(.headline)
                    if attendees.isEmpty {
                        Text("No confirmed attendees yet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(attendees) { attendee in
                            Button(action: {
                                showingAttendeeProfile = attendee
                            }) {
                                HStack {
                                    Text(attendee.username)
                                        .font(.subheadline)
                                    Spacer()
                                    Text("✓")
                                        .foregroundColor(.green)
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Divider()
                
                // Line Section (Pending Requests)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Line (\(pendingRequests.count))")
                        .font(.headline)
                    if pendingRequests.isEmpty {
                        Text("No pending requests")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(pendingRequests) { request in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(request.username)
                                        .font(.subheadline)
                                    if let bio = request.bio {
                                        Text(bio)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                HStack(spacing: 8) {
                                    Button(action: {
                                        showingUserProfile = request
                                    }) {
                                        Image(systemName: "person.circle")
                                    }
                                    Button(action: {
                                        Task {
                                            _ = try? await viewModel.acceptRequest(partyId: party.id, requestId: request.request_id)
                                            loadRequests()
                                        }
                                    }) {
                                        Text("Accept")
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.green)
                                            .foregroundColor(.white)
                                            .cornerRadius(6)
                                            .font(.caption)
                                    }
                                    Button(action: {
                                        Task {
                                            _ = try? await viewModel.rejectRequest(partyId: party.id, requestId: request.request_id)
                                            loadRequests()
                                        }
                                    }) {
                                        Text("Decline")
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.red)
                                            .foregroundColor(.white)
                                            .cornerRadius(6)
                                            .font(.caption)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Party Details")
        .onAppear {
            loadRequests()
        }
        .sheet(item: $showingUserProfile) { request in
            UserProfileDetailView(request: request)
        }
        .sheet(item: $showingAttendeeProfile) { attendee in
            AttendeeProfileView(attendee: attendee)
        }
    }
    
    private func loadRequests() {
        isLoading = true
        Task {
            do {
                async let requestsTask = viewModel.getPartyRequests(partyId: party.id)
                async let attendeesTask = viewModel.getPartyAttendees(partyId: party.id)
                
                let requestsResponse = try await requestsTask
                let attendeesResponse = try await attendeesTask
                
                requests = requestsResponse.requests
                attendees = attendeesResponse.attendees
            } catch {
                print("Error loading party data: \(error)")
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

struct UserProfileDetailView: View {
    let request: api.partyRequest
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text(request.username)
                    .font(.title)
                    .bold()
                
                if let email = request.email {
                    Text("Email: \(email)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let bio = request.bio {
                    Text("Bio:")
                        .font(.headline)
                    Text(bio)
                        .font(.body)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("User Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AttendeeProfileView: View {
    let attendee: api.attendee
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text(attendee.username)
                    .font(.title)
                    .bold()
                
                if let email = attendee.email {
                    Text("Email: \(email)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let bio = attendee.bio {
                    Text("Bio:")
                        .font(.headline)
                    Text(bio)
                        .font(.body)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Attendee Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

