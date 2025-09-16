//
//  PartyFinding.swift
//  partytime
//
//  Created by Curtis on 2025-08-09.
//

import Foundation

class PartyFinding : ObservableObject{
    private var apii : api
    private var auth : authServiceProtocol
    init(apii: api = api.shared, auth : authServiceProtocol = authService.shared) {
        self.apii = apii
        self.auth = auth
    }
    func filterParties(filters : api.PartyFilters = api.PartyFilters()) async throws -> api.partylist{
        do{
            return try await apii.request(method: "POST", path: api.baseurl + "/parties/filter", body: filters.self, returnstruct: api.partylist.self)
        }
        catch{
            print("broken back end")
            return api.partylist(parties: [])
        }
    }
    func join(partyid : Int) async throws -> api.messageint{
        do{
            return try await apii.request(method: "POST", path: api.baseurl + "/parties/\(partyid)/join", body: "", returnstruct: api.messageint.self)
        }
        catch{
            print("fuck mane u cant join the party")
            return api.messageint(message: "unlucky", id: -1)
        }
    }
}
