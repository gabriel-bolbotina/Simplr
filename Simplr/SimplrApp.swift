//
//  SimplrApp.swift
//  Simplr
//
//  Created by Gabriel Bolbotina on 27.08.2024.
//

import SwiftUI
import SwiftData

@main
struct SimplrApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Board.self, TaskItem.self, Category.self, Shortcut.self])
    }
}
