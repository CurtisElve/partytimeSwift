//
//  ContentView.swift
//  partytime
//
//  Created by Curtis on 2025-07-27.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = LoginViewModel()
    @ObservedObject private var authservice : authService = authService.shared
    var body: some View {
        if authservice.isAuthenticated {
            mainView(viewModel: self.viewModel)
        }
        else{
            login(viewModel: self.viewModel)
        }
    }
}

#Preview {
    ContentView()
}
