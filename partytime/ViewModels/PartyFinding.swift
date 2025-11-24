//
//  PartyFinding.swift
//  partytime
//
//  Created by Curtis on 2025-08-09.
//

import Foundation

class PartyFinding : ObservableObject{
    @Published var joinedparties : [Int] = []
    private var apii : api
    private var auth : authServiceProtocol
    init(apii: api = api.shared, auth : authServiceProtocol = authService.shared) {
        self.apii = apii
        self.auth = auth
    }
    func getJoined() async throws -> [String:[Int]]{
        do {
            return try await apii.request(method: "GET", path: "/users/joined-parties", returnstruct: [String:[Int]].self)
        }
        catch{
            print("ids not working ahhh")
            return ["bru":[]]
        }
    }
    func filterParties(filters : api.PartyFilters = api.PartyFilters()) async throws -> api.partylist{
        do{
            return try await apii.request(method: "POST", path: "/parties/filter", body: filters.self, returnstruct: api.partylist.self)
        }
        catch{
            print("broken back end\(error)")
            return api.partylist(parties: [])
        }
    }
    func join(partyid : Int) async throws -> api.messageint{
        do{
            return try await apii.request(method: "POST", path: "/parties/\(partyid)/join", returnstruct: api.messageint.self)
        }
        catch{
            print("fuck mane u cant join the party")
            return api.messageint(message: "unlucky", id: -1)
        }
    }
}
