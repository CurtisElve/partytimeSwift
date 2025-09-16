//
//  api.swift
//  partytime
//
//  Created by Curtis on 2025-07-29.
//

import Foundation

class api{
    var authservice : authServiceProtocol
    init(authservice: authServiceProtocol = authService.shared) {
        self.authservice = authservice
    }
    
    enum APIError: Error {
        case invalidURL
        case requestFailed(Error)
        case invalidResponse
        case decodingError(Error)
        case serverError(Int, Data?)
    }
    static let shared = api()
    static let baseurl = "http://192.168.2.219:8000"
    func request<T:Decodable>(method: String, path: String, body: Encodable? = nil, returnstruct: T.Type) async throws -> T{
        print(path)
        let url = URL(string: path)!
        var request = URLRequest(url: url)
        request.httpMethod = method
        let idToken : String = await authservice.idtoken()!
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = body {
            request.httpBody = try! JSONEncoder().encode(body)
            print(try JSONEncoder().encode(body))
        }
        let (data, response) = try! await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode, data)
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    struct messageint: Decodable {
        let message: String
        let id: Int
        init(message: String, id: Int) {
            self.message = message
            self.id = id
        }
    }
    struct newUser: Codable {
        let email : String
        let username : String
        let phone : String
        let bio : String
        init(email: String, username: String, phone: String, bio: String) {
            self.email = email
            self.username = username
            self.phone = phone
            self.bio = bio
        }
    }
    struct baseParty: Decodable, Identifiable{
        let id : Int
        let name : String
        let description : String
        let distance : Float
        let attendee_count : Int
        let max_attendees : Int
        let start_time : Date
        let end_time : Date
        let hashtags : String
    }
    struct partylist : Decodable {
        let parties : [baseParty]
    }
    struct PartyFilters: Codable {
        var sort_by: String
        var hashtags: String
        var location_radius: LocationRadius?
        var date_range: DateRange?
        let host_id: Int?
        let ticketsLeft: Int?
        
        // Nested structs for complex types
        struct LocationRadius: Codable {
            let lat: Double?
            let lng: Double?
            let radius_km: Int?
            init(lat: Double?, lng: Double?, radius_km: Int?) {
                self.lat = lat
                self.lng = lng
                self.radius_km = radius_km
            }
        }
        
        struct DateRange: Codable {
            let start: String?  // "2024-01-01" format
            let end: String?    // "2024-12-31" format
            init(start: Date?, end: Date?) {
                self.start = start?.ISO8601Format()
                self.end = end?.ISO8601Format()
            }
        }
        
        // Convenience initializer
        init(hashtags: String = "",
             sort_by : String = "",
             latt : Double? = nil,
             lngg : Double? = nil,
             radius_kmm: Int? = nil,
             startt : Date? = nil,
             endd : Date? = nil,
             host_id: Int? = nil,
             ticketsLeft: Int? = nil) {
            self.sort_by = sort_by
            self.hashtags = hashtags
            self.location_radius = LocationRadius(lat: latt, lng: lngg, radius_km: radius_kmm)
            self.date_range = DateRange(start: startt, end: endd)
            self.host_id = host_id
            self.ticketsLeft = ticketsLeft
        }
    }
}
