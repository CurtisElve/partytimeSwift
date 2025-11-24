//
//  PartyDetailsViewModel.swift
//  partytime
//
//  Created by Curtis on 2025-10-09.
//

import Foundation

class PartyDetailsViewModel: ObservableObject {
    @Published var partyDetails: api.partyDetails?
    private var apii: api
    private var auth: authServiceProtocol
    
    init(apii: api = api.shared, auth: authServiceProtocol = authService.shared) {
        self.apii = apii
        self.auth = auth
    }
    
    func getPartyDetails(partyId: Int) async throws -> api.partyDetails {
        do {
            let details = try await apii.request(
                method: "GET",
                path: "/parties/\(partyId)/details",
                returnstruct: api.partyDetails.self
            )
            self.partyDetails = details
            return details
        } catch {
            print("Error getting party details: \(error)")
            throw error
        }
    }
    
    func saveParty(partyId: Int) async throws -> Bool {
        do {
            let _ = try await apii.request(
                method: "POST",
                path: "/users/saved-parties/\(partyId)",
                returnstruct: api.messageint.self
            )
            // Refresh details to update is_saved
            _ = try await getPartyDetails(partyId: partyId)
            return true
        } catch {
            print("Error saving party: \(error)")
            return false
        }
    }
    
    func unsaveParty(partyId: Int) async throws -> Bool {
        do {
            let _ = try await apii.request(
                method: "DELETE",
                path: "/users/saved-parties/\(partyId)",
                returnstruct: api.messageint.self
            )
            // Refresh details to update is_saved
            _ = try await getPartyDetails(partyId: partyId)
            return true
        } catch {
            print("Error unsaving party: \(error)")
            return false
        }
    }
    
    func buyTicket(partyId: Int) async throws -> Bool {
        do {
            let _ = try await apii.request(
                method: "POST",
                path: "/parties/\(partyId)/join",
                returnstruct: api.messageint.self
            )
            // Refresh details to update has_request
            _ = try await getPartyDetails(partyId: partyId)
            return true
        } catch {
            print("Error buying ticket: \(error)")
            return false
        }
    }
}

