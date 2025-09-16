//
//  LoginViewModel.swift
//  partytime
//
//  Created by Curtis on 2025-07-27.
//

import Foundation

class LoginViewModel : ObservableObject{
    @Published var username: String = ""
    @Published var password : String = ""
    @Published var invalidated: Bool = false
    @Published var errormessage = "ahhhhhhhhh"
    private var authenticationService: authServiceProtocol
    
    init(authenticationService: authServiceProtocol = authService.shared){
        self.authenticationService = authenticationService
    }
    func validateCreds(){
        invalidated = username.isEmpty
        signIn()
    }
    func signIn(){
        authenticationService.login(email: username, password: password, completion: { [self]success, error in
            if success{
                print("yurrrrr")
                print(authenticationService.whoisit())
                print(authenticationService.uid()!)
            }
            else if error != nil{
                print(error!)
            }
        })
    }
    func logout(){
        authenticationService.logout(completion: {success, error  in
            DispatchQueue.main.async {
                if success{
                    print("logged out")
                }
                else{
                    print(error!)
                }
            }
        })
    }
}
