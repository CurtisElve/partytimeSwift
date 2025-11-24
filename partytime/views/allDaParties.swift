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
            if parties.count > 0 {
                List {
                    ForEach(parties) { party in
                        NavigationLink(destination: singleParty(party: party)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(party.name)
                                        .font(.headline)
                                    if let hashtags = party.hashtags {
                                        Text(hashtags)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Text("\(party.attendee_count)/\(party.max_attendees) attendees")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            } else {
                Text("dead ash in here :((")
                Spacer()
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
                print("Error searching parties: \(error)")
            }
        }
    }
}
#Preview{PartyFilterView()}
