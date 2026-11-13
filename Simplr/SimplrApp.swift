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
    /// One container shared by every scene, so edits in Settings show up in the main window immediately.
    let container: ModelContainer = {
        do {
            return try ModelContainer(for: Board.self, TaskItem.self, Category.self, Shortcut.self)
        } catch {
            fatalError("Couldn't open the data store: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 720, minHeight: 480)
        }
        .defaultSize(width: 1000, height: 680)
        .commands { AppCommands() }
        .modelContainer(container)

        Settings {
            SettingsView()
        }
        .modelContainer(container)
    }
}
