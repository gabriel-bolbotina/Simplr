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
