//
//  authService.swift
//  partytime
//
//  Created by Curtis on 2025-07-27.
//

import Foundation
import FirebaseAuth
class authService : ObservableObject {
    @Published var isAuthenticated = false
    @Published var lat = 0.0
    static let shared = authService()
    
    private init(){
        if Auth.auth().currentUser != nil{
            self.isAuthenticated = true
        }
    }
    
    func logout(completion: @escaping (Bool, (any Error)?) -> Void) {
        do{
            try Auth.auth().signOut()
            self.isAuthenticated = false
        }
        catch{
            completion(false, error)
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Bool, (any Error)?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) {AuthDataResult, error in
            if (AuthDataResult?.user) != nil{
                completion(true, nil)
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                }
            }
            else{
                completion(false, error)
            }
        }
    }
    
    func SignUp(email: String, password: String, completion: @escaping (Bool, (any Error)?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) {AuthDataResult, error in
            if (AuthDataResult?.user) != nil{
                completion(true, nil)
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                }
            }
            else{
                completion(false, error)
            }
        }
    }
    
    func whoisit() -> String {
        return Auth.auth().currentUser?.email ?? "not logged in"
    }
    
    func uid() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func idtoken() async -> String? {
        guard let user = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return nil
        }

        do {
            return try await user.getIDToken()
        } catch {
            print("Error getting ID token: \(error.localizedDescription)")
            return nil
        }
    }
    func newidtoken() async -> String? {
        guard let user = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return nil
        }

        do {
            return try await user.getIDToken(forcingRefresh: true)
        } catch {
            print("Error getting ID token: \(error.localizedDescription)")
            return nil
        }
    }
}
