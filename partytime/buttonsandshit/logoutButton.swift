//
//  logoutButton.swift
//  partytime
//
//  Created by Curtis on 2025-07-27.
//

import SwiftUI

struct logoutButton: View {
    
    @ObservedObject var viewModel : LoginViewModel
    var body: some View {
        Button(action: viewModel.logout, label: {Text("sign out")})
    }
}
