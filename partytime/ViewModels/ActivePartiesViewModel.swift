//
//  ActivePartiesViewModel.swift
//  partytime
//
//  Created by Curtis on 2025-10-09.
//

import Foundation

class ActivePartiesViewModel: ObservableObject {
    @Published var pendingParties: [api.partyWithRequest] = []
    @Published var acceptedParties: [api.partyWithRequest] = []
    private var apii: api
    private var auth: authServiceProtocol
    
    init(apii: api = api.shared, auth: authServiceProtocol = authService.shared) {
        self.apii = apii
        self.auth = auth
    }
    
    func getActiveParties() async throws -> api.activeParties {
        do {
            return try await apii.request(
                method: "GET",
                path: "/users/active-parties",
                returnstruct: api.activeParties.self
            )
        } catch {
            print("Error getting active parties: \(error)")
            return api.activeParties(pending_parties: [], accepted_parties: [])
        }
    }
}

