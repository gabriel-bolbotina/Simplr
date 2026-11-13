//
//  AppCommands.swift
//  Simplr
//

import SwiftUI

/// A menu action published by the focused view. Equality by `id` keeps
/// SwiftUI from treating every new closure as a change.
struct FocusedAction: Equatable {
    let id: String
    let perform: () -> Void

    func callAsFunction() { perform() }

    static func == (lhs: FocusedAction, rhs: FocusedAction) -> Bool { lhs.id == rhs.id }
}

extension FocusedValues {
    @Entry var newTaskAction: FocusedAction?
    @Entry var newBoardAction: FocusedAction?
}

/// Replaces File › New Window with app-specific New Task (⌘N) and New Board (⇧⌘N).
struct AppCommands: Commands {
    @FocusedValue(\.newTaskAction) private var newTaskAction
    @FocusedValue(\.newBoardAction) private var newBoardAction

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Task") { newTaskAction?() }
                .keyboardShortcut("n")
                .disabled(newTaskAction == nil)
            Button("New Board") { newBoardAction?() }
                .keyboardShortcut("n", modifiers: [.command, .shift])
                .disabled(newBoardAction == nil)
        }
    }
}
