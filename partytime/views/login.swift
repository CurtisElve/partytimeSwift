//
//  login.swift
//  partytime
//
//  Created by Curtis on 2025-07-27.
//

import SwiftUI

struct login: View {
    @ObservedObject var viewModel : LoginViewModel
    @State var signUp : SignUp = SignUp()
    var body: some View {
        NavigationStack {
            VStack {
                Text("the goat is back?!?!?!?")
                TextField("username", text: $viewModel.username)
                TextField("password", text: $viewModel.password)
                HStack {
                    Button(action: viewModel.validateCreds, label: {Text("login!!!")})
                    NavigationLink("new user??", destination: signUpView(viewModel: $signUp))
                }
            }
            .alert(isPresented: $viewModel.invalidated, content: {Alert(
                title: Text("Error"),
                message: Text("bad email :|"),
                dismissButton: .default(Text("OK"))
            )
            }
            )
        }.navigationTitle(Text("login"))
    }
}
