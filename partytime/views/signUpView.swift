//
//  signUpView.swift
//  partytime
//
//  Created by Curtis on 2025-07-27.
//

import SwiftUI

struct signUpView: View {
    @Binding var viewModel : SignUp
    @State var isLoading : Bool = false
    var body: some View {
        NavigationStack {
            VStack {
                Text("welcome aboard?!?!?!?")
                TextField("username", text: $viewModel.username)
                TextField("password", text: $viewModel.password)
                TextField("confirm passwd", text: $viewModel.confirmPassword)
                Button("Sign Up") {
                    Task {
                        isLoading = true
                        await viewModel.validateCreds()
                        isLoading = false
                    }
                }
                .disabled(isLoading)
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
