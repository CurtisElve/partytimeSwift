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
        case notAuthenticated
    }
    static let shared = api()
    static let baseurl = "http://127.0.0.1:8000"
    func request<T:Decodable>(method: String, path: String, body: Encodable? = nil, returnstruct: T.Type) async throws -> T{
        print(path)
        var urlString = path
        if !path.hasPrefix("http") {
            urlString = api.baseurl + path
        }
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Handle authentication - only add token if user is logged in
        if let idToken = await authservice.idtoken() {
            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        } else {
            // Only throw error if this is a protected endpoint (not a login/register endpoint)
            if !path.contains("/register") && !path.contains("/login") {
                throw APIError.notAuthenticated
            }
        }
        if body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try! JSONEncoder().encode(body!)
            print(try JSONEncoder().encode(body!))
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
        let description : String?
        let distance : Float?
        let attendee_count : Int
        let max_attendees : Int
        let start_time : String?
        let end_time : String?
        let hashtags : String?
    }
    
    struct partyDetails: Decodable {
        let id: Int
        let name: String
        let description: String?
        let hashtags: String?
        let attendee_count: Int
        let max_attendees: Int
        let start_time: String?
        let end_time: String?
        let address: String?
        let latitude: Float?
        let longitude: Float?
        let media_url: String?
        let host: HostInfo?
        let is_saved: Bool
        let has_request: Bool
        let request_accepted: Bool
        
        struct HostInfo: Decodable {
            let id: Int
            let username: String
        }
    }
    
    struct activeParties: Decodable {
        let pending_parties: [partyWithRequest]
        let accepted_parties: [partyWithRequest]
    }
    
    struct partyWithRequest: Decodable, Identifiable {
        let id: Int
        let name: String
        let description: String?
        let hashtags: String?
        let attendee_count: Int
        let max_attendees: Int
        let start_time: String?
        let end_time: String?
        let host: partyDetails.HostInfo?
        let request_id: Int
        let accepted: Bool
        let created_at: String?
    }
    
    struct userProfile: Decodable {
        let id: Int
        let email: String?
        let username: String
        let phone: String?
        let bio: String?
        let pfpURL: String?
        let isHost: Bool
    }
    
    struct updateUser: Codable {
        let username: String?
        let phone: String?
        let bio: String?
        let pfpURL: String?
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
    struct makeparty : Codable{
        var name:String
        var description:String
        var latitude:Float
        var longitude:Float
        var address:String
        var starttime:String
        var endtime:String
        var maxattendees:Int
        var hashtags:String
        var image:String
        init(name: String, description: String, latitude: Float, longitude: Float, address: String, starttime: Date, endtime: Date, maxattendees: Int, hashtags: String, image: String) {
            self.name = name
            self.description = description
            self.latitude = latitude
            self.longitude = longitude
            self.address = address
            self.starttime = starttime.ISO8601Format()
            self.endtime = endtime.ISO8601Format()
            self.maxattendees = maxattendees
            self.hashtags = hashtags
            self.image = image
        }
    }
    
    struct savedPartiesResponse: Decodable {
        let saved_parties: [baseParty]
    }
    
    // Host-related structs
    struct hostParty: Decodable, Identifiable {
        let id: Int
        let name: String
        let description: String?
        let hashtags: String?
        let attendee_count: Int
        let max_attendees: Int
        let start_time: String?
        let end_time: String?
        let address: String?
        let latitude: Float?
        let longitude: Float?
    }
    
    struct hostPartiesResponse: Decodable {
        let active_parties: [hostParty]
        let past_parties: [hostParty]
        let future_parties: [hostParty]
    }
    
    struct partyRequest: Decodable, Identifiable {
        let request_id: Int
        let user_id: Int
        let username: String
        let email: String?
        let bio: String?
        let pfpURL: String?
        let accepted: Bool
        let created_at: String?
        
        var id: Int { request_id }
    }
    
    struct partyRequestsResponse: Decodable {
        let requests: [partyRequest]
    }
    
    struct attendee: Decodable, Identifiable {
        let user_id: Int
        let username: String
        let email: String?
        let bio: String?
        let pfpURL: String?
        
        var id: Int { user_id }
    }
    
    struct attendeesResponse: Decodable {
        let attendees: [attendee]
    }
    
    struct createPartyRequest: Codable {
        let name: String
        let description: String?
        let latitude: Float?
        let longitude: Float?
        let address: String?
        let start_time: String?
        let end_time: String?
        let max_attendees: Int?
        let hashtags: String?
        let media_url: String?
        
        init(name: String, description: String? = nil, latitude: Float? = nil, longitude: Float? = nil, address: String? = nil, startTime: Date? = nil, endTime: Date? = nil, maxAttendees: Int? = nil, hashtags: String? = nil, mediaUrl: String? = nil) {
            self.name = name
            self.description = description
            self.latitude = latitude
            self.longitude = longitude
            self.address = address
            self.start_time = startTime?.ISO8601Format()
            self.end_time = endTime?.ISO8601Format()
            self.max_attendees = maxAttendees
            self.hashtags = hashtags
            self.media_url = mediaUrl
        }
    }
}
