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
                .frame(minWidth: 720, minHeight: 480)
        }
        .defaultSize(width: 1000, height: 680)
        .modelContainer(for: [Board.self, TaskItem.self, Category.self, Shortcut.self])
    }
}
