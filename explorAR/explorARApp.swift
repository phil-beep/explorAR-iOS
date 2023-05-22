//
//  explorARApp.swift
//  explorAR
//
//  Created by Philipp-Michael Handke on 04.02.23.
//

import SwiftUI

@main
struct explorARApp: App {
    @AppStorage("firstStart") private var firstStart = true
    var body: some Scene {
        WindowGroup {
            if(firstStart){
                TutorialView()
            } else {
                ContentView()
            }
        }
    }
}
