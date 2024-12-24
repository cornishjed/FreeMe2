//
//  FreeMeApp.swift
//  FreeMe
//
//  Created by Jed Powell on 08/02/2022.
//

import SwiftUI
import Firebase

@main
struct FreeMeApp: App {

    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
