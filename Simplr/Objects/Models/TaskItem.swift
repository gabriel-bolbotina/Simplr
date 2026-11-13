//
//  TaskItem.swift
//  Simplr
//

import Foundation
import SwiftData

enum Priority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

enum TaskStatus: String, Codable, CaseIterable {
    case todo
    case inProgress
    case done
}

@Model
final class TaskItem {
    var id: UUID = UUID()
    var title: String = ""
    var notes: String = ""
    var dueDate: Date?
    var priority: Priority = Priority.medium
    var sortOrder: Int = 0
    var createdAt: Date = Date()

    // Read these freely, but change them only through setProgress(_:) and move(to:)
    // so progress and status never disagree (D-004).
    var progress: Double = 0
    var status: TaskStatus = TaskStatus.todo
    var completedAt: Date?
    var progressBeforeDone: Double?

    var board: Board?
    var category: Category?

    @Relationship(deleteRule: .cascade, inverse: \Shortcut.task)
    var shortcuts: [Shortcut]? = []

    init(
        title: String,
        notes: String = "",
        dueDate: Date? = nil,
        priority: Priority = .medium,
        board: Board? = nil,
        category: Category? = nil
    ) {
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.priority = priority
        self.board = board
        self.category = category
    }
}

// MARK: - Progress & status rules (D-004)

extension TaskItem {
    /// Slider path: 0 % → To Do, 1–99 % → In Progress, 100 % → Done.
    func setProgress(_ value: Double, now: Date = .now) {
        let clamped = min(max(value, 0), 1)
        if clamped >= 1 {
            move(to: .done, now: now)
            return
        }
        progress = clamped
        progressBeforeDone = nil
        completedAt = nil
        status = clamped > 0 ? .inProgress : .todo
    }

    /// Kanban path: Done forces 100 %, To Do forces 0 %, and leaving Done
    /// restores the progress the task had before it was completed.
    func move(to newStatus: TaskStatus, now: Date = .now) {
        switch newStatus {
        case .todo:
            progress = 0
            progressBeforeDone = nil
            completedAt = nil
        case .inProgress:
            if status == .done {
                progress = progressBeforeDone ?? 0
            }
            progressBeforeDone = nil
            completedAt = nil
        case .done:
            if status != .done {
                progressBeforeDone = progress
                completedAt = now
            }
            progress = 1
        }
        status = newStatus
    }

    var remainingDays: Int? {
        guard let dueDate else { return nil }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: calendar.startOfDay(for: .now), to: calendar.startOfDay(for: dueDate)).day
    }
}
