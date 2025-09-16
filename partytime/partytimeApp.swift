//
//  partytimeApp.swift
//  partytime
//
//  Created by Curtis on 2025-07-27.
//

import SwiftUI
import Firebase
@main
struct partytimeApp: App {
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
