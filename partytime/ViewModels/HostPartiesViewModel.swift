//
//  HostPartiesViewModel.swift
//  partytime
//
//  Created by Curtis on 2025-10-09.
//

import Foundation

class HostPartiesViewModel: ObservableObject {
    @Published var activeParties: [api.hostParty] = []
    @Published var pastParties: [api.hostParty] = []
    @Published var futureParties: [api.hostParty] = []
    private var apii: api
    private var auth: authServiceProtocol
    
    init(apii: api = api.shared, auth: authServiceProtocol = authService.shared) {
        self.apii = apii
        self.auth = auth
    }
    
    func getHostParties() async throws -> api.hostPartiesResponse {
        do {
            return try await apii.request(
                method: "GET",
                path: "/hosts/parties",
                returnstruct: api.hostPartiesResponse.self
            )
        } catch {
            print("Error getting host parties: \(error)")
            return api.hostPartiesResponse(active_parties: [], past_parties: [], future_parties: [])
        }
    }
    
    func getPartyRequests(partyId: Int) async throws -> api.partyRequestsResponse {
        do {
            return try await apii.request(
                method: "GET",
                path: "/hosts/parties/\(partyId)/requests",
                returnstruct: api.partyRequestsResponse.self
            )
        } catch {
            print("Error getting party requests: \(error)")
            return api.partyRequestsResponse(requests: [])
        }
    }
    
    func getPartyAttendees(partyId: Int) async throws -> api.attendeesResponse {
        do {
            return try await apii.request(
                method: "GET",
                path: "/hosts/parties/\(partyId)/attendees",
                returnstruct: api.attendeesResponse.self
            )
        } catch {
            print("Error getting party attendees: \(error)")
            return api.attendeesResponse(attendees: [])
        }
    }
    
    func acceptRequest(partyId: Int, requestId: Int) async throws -> Bool {
        do {
            struct MessageResponse: Decodable {
                let message: String
            }
            let _ = try await apii.request(
                method: "POST",
                path: "/hosts/parties/\(partyId)/requests/\(requestId)/accept",
                returnstruct: MessageResponse.self
            )
            return true
        } catch {
            print("Error accepting request: \(error)")
            return false
        }
    }
    
    func rejectRequest(partyId: Int, requestId: Int) async throws -> Bool {
        do {
            struct MessageResponse: Decodable {
                let message: String
            }
            let _ = try await apii.request(
                method: "POST",
                path: "/hosts/parties/\(partyId)/requests/\(requestId)/reject",
                returnstruct: MessageResponse.self
            )
            return true
        } catch {
            print("Error rejecting request: \(error)")
            return false
        }
    }
}

