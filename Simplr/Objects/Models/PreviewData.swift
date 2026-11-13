//
//  PreviewData.swift
//  Simplr
//

import Foundation
import SwiftData

/// In-memory sample data for SwiftUI previews.
@MainActor
enum PreviewData {
    static let schema = Schema([Board.self, TaskItem.self, Category.self, Shortcut.self])

    static let container: ModelContainer = {
        let container = try! ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = container.mainContext

        let work = Category(name: "Work", colorHex: "#0A84FF")
        let life = Category(name: "Life", colorHex: "#FF9F0A", pattern: .dots)
        let personal = Board(name: "Personal", symbol: "house", sortOrder: 0)
        let simplr = Board(name: "Simplr", symbol: "sparkles", sortOrder: 1)
        [work, life].forEach(context.insert)
        [personal, simplr].forEach(context.insert)

        let groceries = TaskItem(title: "Buy groceries", notes: "Milk, eggs, coffee", dueDate: .now.addingTimeInterval(86_400), priority: .low, board: personal, category: life)
        let glass = TaskItem(title: "Glass slider spike", notes: "Try glassEffectID morphing", dueDate: .now.addingTimeInterval(5 * 86_400), priority: .high, board: simplr, category: work)
        glass.setProgress(0.4)
        let docs = TaskItem(title: "Write product docs", priority: .medium, board: simplr, category: work)
        docs.move(to: .done)
        [groceries, glass, docs].forEach(context.insert)

        context.insert(Shortcut(kind: .url, target: "https://developer.apple.com/documentation/swiftui", title: "SwiftUI docs", task: glass))
        context.insert(Shortcut(kind: .app, target: "com.apple.dt.Xcode", title: "Xcode", task: glass))
        return container
    }()

    static var sampleTask: TaskItem {
        try! container.mainContext.fetch(FetchDescriptor<TaskItem>()).first { $0.status == .inProgress }!
    }
}
