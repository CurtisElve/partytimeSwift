//
//  makeparty.swift
//  partytime
//
//  Created by Curtis on 2025-09-17.
//
// becomehost if not host - makeparty if host just easy shit honestly nothing that deep
import SwiftUI

struct makeparty: View {
    @StateObject private var partymaker : createParty = createParty()
    var body: some View {
        TextField("name", text: $partymaker.name)
        TextField("description", text: $partymaker.description)
        TextField("address", text:$partymaker.address)
        TextField("hashtags", text:$partymaker.hashtags)
        DatePicker("from", selection: $partymaker.endtime)
        DatePicker("until", selection: $partymaker.endtime)
        //location picker + address maybe?
        //max attendees
        //media upload
    }
}

#Preview {
    makeparty()
}
