//
//  TicketView.swift
//  partytime
//
//  Created by Curtis on 2025-10-09.
//

import SwiftUI

struct TicketView: View {
    let party: api.partyWithRequest
    @State private var showingTicket = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Your Ticket")
                    .font(.largeTitle)
                    .bold()
                
                // Placeholder ticket
                VStack(spacing: 16) {
                    Text(party.name)
                        .font(.title)
                        .bold()
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        if let startTime = party.start_time {
                            Text("Date: \(formatDate(startTime))")
                        }
                        if let address = party.host?.username {
                            Text("Host: \(address)")
                        }
                        Text("Attendee Count: \(party.attendee_count)")
                    }
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    
                    // Placeholder QR code area
                    ZStack {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 200, height: 200)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                        Text("QR Code\nPlaceholder")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Present this ticket at the event")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding()
                
                Text("Note: This is a placeholder ticket. A secure QR code system will be implemented in the future.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .padding()
        }
        .navigationTitle("Ticket")
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

