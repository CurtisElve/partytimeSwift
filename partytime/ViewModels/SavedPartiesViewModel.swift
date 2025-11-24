//
//  SavedPartiesViewModel.swift
//  partytime
//
//  Created by Curtis on 2025-10-09.
//

import Foundation

class SavedPartiesViewModel: ObservableObject {
    @Published var savedParties: [api.baseParty] = []
    private var apii: api
    private var auth: authServiceProtocol
    
    init(apii: api = api.shared, auth: authServiceProtocol = authService.shared) {
        self.apii = apii
        self.auth = auth
    }
    
    func getSavedParties() async throws -> [api.baseParty] {
        do {
            let response = try await apii.request(
                method: "GET",
                path: "/users/saved-parties",
                returnstruct: api.savedPartiesResponse.self
            )
            return response.saved_parties
        } catch {
            print("Error getting saved parties: \(error)")
            return []
        }
    }
    
    func removeSavedParty(partyId: Int) async throws -> Bool {
        do {
            let _ = try await apii.request(
                method: "DELETE",
                path: "/users/saved-parties/\(partyId)",
                returnstruct: api.messageint.self
            )
            return true
        } catch {
            print("Error removing saved party: \(error)")
            return false
        }
    }
}

