//
//  PaymentView.swift
//  partytime
//
//  Created by Curtis on 2025-10-09.
//

import SwiftUI

struct PaymentView: View {
    let partyId: Int
    @ObservedObject var viewModel: PartyDetailsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Payment Placeholder")
                    .font(.title)
                    .padding()
                
                Text("This is a placeholder payment screen.")
                    .foregroundColor(.secondary)
                
                Text("In production, this would integrate with Stripe or another payment provider.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Placeholder payment info
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ticket Price: $0.00")
                        .font(.headline)
                    Text("Payment Method: Not implemented")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                Button(action: {
                    Task {
                        do {
                            _ = try await viewModel.buyTicket(partyId: partyId)
                            showingSuccess = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                dismiss()
                            }
                        } catch {
                            print("Error purchasing ticket: \(error)")
                        }
                    }
                }) {
                    Text("Complete Purchase (Placeholder)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Purchase Complete!", isPresented: $showingSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your ticket request has been submitted. You'll be notified when the host accepts.")
            }
        }
    }
}

