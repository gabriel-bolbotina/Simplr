//
//  SimplrApp.swift
//  Simplr
//
//  Created by Gabriel Bolbotina on 27.08.2024.
//

import SwiftUI
import SwiftData

@main
struct new_swift_appApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: TaskObject.self)
    }
}
