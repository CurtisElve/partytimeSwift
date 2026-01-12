//
//  SignUp.swift
//  partytime
//
//  Created by Curtis on 2025-07-28.
//
import Foundation

class SignUp : ObservableObject{
    @Published var username: String = ""
    @Published var password : String = ""
    @Published var confirmPassword: String = ""
    @Published var invalidated: Bool = false
    @Published var errormessage = "ahhhhhhhhh"
    private var authenticationService: authServiceProtocol
    private var apii : api
    init(authenticationService: authServiceProtocol = authService.shared){
        self.authenticationService = authenticationService
        self.apii = api.shared
    }
    func validateCreds() async {
        invalidated = username.isEmpty && password.isEmpty && confirmPassword.isEmpty && password != confirmPassword
        if !invalidated {
            let signUpSuccess = await signUp()  // This will actually wait!
            
            if signUpSuccess {
                let thingy : api.messageint = await backendRegister()
                print(thingy.message, thingy.id)
            } else {
                print("Sign up failed, not getting token")
            }
        }
    }
    func signUp() async -> Bool {
        return await withCheckedContinuation { continuation in
            self.authenticationService.SignUp(email: username, password: password) { success, error in
                if success {
                    print("yurrrrr")
                    print(self.authenticationService.whoisit())
                    print(self.authenticationService.uid()!)
                    continuation.resume(returning: true)
                } else if let error = error {
                    print(error)
                    continuation.resume(returning: false)
                } else {
                    print("Unknown error")
                    continuation.resume(returning: false)
                }
            }
        }
    }
    func backendRegister() async -> api.messageint{
        let newuser = api.newUser(email: username, username: "mrwhiskers", phone: "1234567890", bio:"asdfasdf")
        do{
            let token : String = await self.authenticationService.newidtoken() ?? ""
            print("token here ->>> \(token)")
            return try await apii.request(method: "POST", path: "/register", body:newuser.self, returnstruct: api.messageint.self, usertoken: token)
        }
        catch{
            print("broken back end")
            return api.messageint(message: "broken backend", id: -1)
        }
    }
    
}
