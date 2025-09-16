//
//  mainView.swift
//  partytime
//
//  Created by Curtis on 2025-07-27.
//

import SwiftUI

struct mainView: View {
    @ObservedObject var viewModel : LoginViewModel
    var body: some View {
        logoutButton(viewModel: self.viewModel)
    }
}
