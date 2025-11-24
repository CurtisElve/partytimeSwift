//
//  ProfileViewModel.swift
//  partytime
//
//  Created by Curtis on 2025-10-09.
//

import Foundation

class ProfileViewModel: ObservableObject {
    @Published var profile: api.userProfile?
    @Published var username: String = ""
    @Published var phone: String = ""
    @Published var bio: String = ""
    @Published var pfpURL: String = ""
    private var apii: api
    private var auth: authServiceProtocol
    
    init(apii: api = api.shared, auth: authServiceProtocol = authService.shared) {
        self.apii = apii
        self.auth = auth
    }
    
    func getUserProfile() async throws -> api.userProfile {
        do {
            let profile = try await apii.request(
                method: "GET",
                path: "/users/profile",
                returnstruct: api.userProfile.self
            )
            self.profile = profile
            self.username = profile.username
            self.phone = profile.phone ?? ""
            self.bio = profile.bio ?? ""
            self.pfpURL = profile.pfpURL ?? ""
            return profile
        } catch {
            print("Error getting user profile: \(error)")
            throw error
        }
    }
    
    func updateProfile() async throws -> api.userProfile {
        do {
            let updateData = api.updateUser(
                username: username.isEmpty ? nil : username,
                phone: phone.isEmpty ? nil : phone,
                bio: bio.isEmpty ? nil : bio,
                pfpURL: pfpURL.isEmpty ? nil : pfpURL
            )
            struct UpdateResponse: Decodable {
                let message: String
                let user: api.userProfile
            }
            let response = try await apii.request(
                method: "PUT",
                path: "/users/profile",
                body: updateData,
                returnstruct: UpdateResponse.self
            )
            self.profile = response.user
            return response.user
        } catch {
            print("Error updating profile: \(error)")
            throw error
        }
    }
}

