//
//  HostViewModel.swift
//  partytime
//
//  Created by Curtis on 2025-10-09.
//

import Foundation

class HostViewModel: ObservableObject {
    @Published var partyCount: Int = 0
    private var apii: api
    private var auth: authServiceProtocol
    
    init(apii: api = api.shared, auth: authServiceProtocol = authService.shared) {
        self.apii = apii
        self.auth = auth
    }
    
    func becomeHost() async throws -> Bool {
        do {
            struct BecomeHostResponse: Decodable {
                let message: String
            }
            let _ = try await apii.request(
                method: "POST",
                path: "/users/become-host",
                returnstruct: BecomeHostResponse.self
            )
            return true
        } catch {
            print("Error becoming host: \(error)")
            throw error
        }
    }
    
    func getPartyCount() async throws -> Int {
        do {
            struct PartyCountResponse: Decodable {
                let party_count: Int
            }
            let response = try await apii.request(
                method: "GET",
                path: "/hosts/party-count",
                returnstruct: PartyCountResponse.self
            )
            self.partyCount = response.party_count
            return response.party_count
        } catch {
            print("Error getting party count: \(error)")
            return 0
        }
    }
}

