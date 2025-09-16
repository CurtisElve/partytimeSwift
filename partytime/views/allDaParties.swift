import Foundation
import SwiftUI
import CoreLocation
struct PartyFilterView: View {
    @StateObject private var viewModel = PartyFinding()
    @State private var parties: [api.baseParty] = []
    @State private var filters : api.PartyFilters = api.PartyFilters()
    enum sort_by: String, CaseIterable, Identifiable {
        case distance = "distance"
        case time = "time"
        case phrase = "phrase"
        var id: Self { self }
    }

    @State private var selectedFlavor: sort_by = .distance
    var body: some View {
        VStack {
            Picker("sort by", selection: $selectedFlavor){
                ForEach(sort_by.allCases) { flavor in
                    Text(flavor.rawValue.capitalized)
                }
            }
            .onChange(of: selectedFlavor, {
                self.filters.sort_by = selectedFlavor.rawValue
                self.searchParties()
            })
            HStack{
                TextField("search", text:self.$filters.hashtags)
                Button(action: self.searchParties, label: {Text("search")})
            }
            List{ ForEach(parties) { party in
                    HStack{
                        Text(party.name)
                        Spacer()
                        Button(action:{ self.join(id: party.id)}, label:{Text("join")})
                    }
                }
            }
        }
        .pickerStyle(.segmented)
        .onAppear {
            CLLocationManager().requestWhenInUseAuthorization()
            searchParties()
        }
    }
    private func searchParties() {
        let longg = CLLocationManager().location?.coordinate.longitude
        let latt = CLLocationManager().location?.coordinate.latitude
        print(latt ?? "fuck", longg ?? "fuck")
        self.filters.location_radius = api.PartyFilters.LocationRadius(lat: latt, lng: longg, radius_km: 10000000)
        let now = Date()
        self.filters.date_range = api.PartyFilters.DateRange(start: now, end:now)
        Task {
            do {
                let results = try await viewModel.filterParties(filters: self.filters)
                self.parties = results.parties
        } catch {
            print("fuckfuckfuck")
            }
        }
    }
    private func join(id : Int){
        Task{
            do {
                let results = try await viewModel.join(partyid: id)
                print(results.message)
        } catch {
            print("fuckfuckfuck")
            }
        }
    }
}
#Preview{PartyFilterView()}
