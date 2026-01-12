//
//  CreatePartyView.swift
//  partytime
//
//  Created by Curtis on 2025-10-09.
//

import SwiftUI

struct CreatePartyView: View {
    @StateObject private var viewModel = createParty()
    @State private var showingSuccess = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Party Details") {
                    TextField("Party Name", text: $viewModel.name)
                    TextField("Description", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Hashtags", text: $viewModel.hashtags)
                }
                
                Section("Location") {
                    TextField("Address", text: $viewModel.address)
                    // Latitude/Longitude would typically come from a map picker
                    // For now, we'll leave them as -1 and handle on backend if needed
                }
                
                Section("Date & Time") {
                    DatePicker("Start Time", selection: $viewModel.starttime)
                    DatePicker("End Time", selection: $viewModel.endtime)
                }
                
                Section("Capacity") {
                    TextField("Max Attendees", value: $viewModel.maxattendees, format: .number)
                }
                
                Section("Media") {
                    TextField("Image URL", text: $viewModel.image)
                }
            }
            .navigationTitle("Create Party")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        submitParty()
                    }
                    .disabled(isLoading || viewModel.name.isEmpty)
                }
            }
            .alert("Party Created!", isPresented: $showingSuccess) {
                Button("OK", role: .cancel) {
                    // Reset form after successful creation
                    viewModel.name = ""
                    viewModel.description = ""
                    viewModel.address = ""
                    viewModel.hashtags = ""
                    viewModel.image = ""
                    viewModel.starttime = Date.now
                    viewModel.endtime = Date.now
                    viewModel.maxattendees = 0
                }
            } message: {
                Text("Your party has been created successfully!")
            }
        }
    }
    
    private func submitParty() {
        isLoading = true
        Task {
            do {
                let partyData = viewModel.makeCreatePartyRequest()
                struct CreatePartyResponse: Decodable {
                    let message: String
                    let id: Int
                }
                let apii = api.shared
                let _ = try await apii.request(
                    method: "POST",
                    path: "/parties/create",
                    body: partyData,
                    returnstruct: CreatePartyResponse.self
                )
                showingSuccess = true
            } catch {
                print("Error creating party: \(error)")
            }
            isLoading = false
        }
    }
}

