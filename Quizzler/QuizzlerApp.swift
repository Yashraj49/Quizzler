//
//  QuizzlerApp.swift
//  Quizzler
//
//  Created by Yashraj jadhav on 10/06/23.
//

import SwiftUI
import Firebase

@main
struct QuizzlerApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
