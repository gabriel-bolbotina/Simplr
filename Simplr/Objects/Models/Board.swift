//
//  Board.swift
//  Simplr
//

import Foundation
import SwiftData

enum BoardViewMode: String, Codable, CaseIterable {
    case list
    case kanban
}

@Model
final class Board {
    var id: UUID = UUID()
    var name: String = ""
    var symbol: String = "checklist"
    var sortOrder: Int = 0
    var preferredView: BoardViewMode = BoardViewMode.list
    var createdAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \TaskItem.board)
    var tasks: [TaskItem]? = []

    init(name: String, symbol: String = "checklist", sortOrder: Int = 0) {
        self.name = name
        self.symbol = symbol
        self.sortOrder = sortOrder
    }

    var sortedTasks: [TaskItem] {
        (tasks ?? []).sorted { ($0.sortOrder, $0.createdAt) < ($1.sortOrder, $1.createdAt) }
    }
}

// MARK: - Kanban ordering

extension Board {
    /// Moves `task` into the `status` column, just before `target`, or to the end
    /// of the column when `target` is nil. Status changes go through
    /// `TaskItem.move(to:)` so progress stays consistent (D-004).
    func place(_ task: TaskItem, in status: TaskStatus, before target: TaskItem? = nil) {
        guard target != task else { return }
        if task.status != status {
            task.move(to: status)
        }
        var column = sortedTasks.filter { $0.status == status && $0 != task }
        let index = target.flatMap { column.firstIndex(of: $0) } ?? column.endIndex
        column.insert(task, at: index)
        for (order, item) in column.enumerated() {
            item.sortOrder = order
        }
    }
}
