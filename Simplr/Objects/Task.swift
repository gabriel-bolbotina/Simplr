//
//  Task.swift
//  Simplr
//
//  Created by Gabriel Bolbotina on 04.03.2025.
//

import Foundation
import SwiftData

enum Priority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

@Model
class TaskObject {
    var id: UUID
    var title: String
    var taskDescription: String
    var dueDate: Date
    var priority: Priority
    var status: Bool
    var progress: Double

    init(title: String, taskDescription: String, dueDate: Date, priority: Priority) {
        self.id = UUID()
        self.title = title
        self.taskDescription = taskDescription
        self.dueDate = dueDate
        self.priority = priority
        self.status = false
        self.progress = 0.0
    }

    func getPriority() -> String {
        return priority.rawValue
    }

    func getRemainingDays() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: dueDate)
        return components.day ?? 0
    }
}
