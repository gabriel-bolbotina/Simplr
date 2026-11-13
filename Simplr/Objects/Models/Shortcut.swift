//
//  Shortcut.swift
//  Simplr
//

import Foundation
import SwiftData

enum ShortcutKind: String, Codable {
    case url
    case app
}

@Model
final class Shortcut {
    var id: UUID = UUID()
    var kind: ShortcutKind = ShortcutKind.url
    /// A URL string for `.url`, a bundle identifier for `.app`.
    var target: String = ""
    var title: String = ""
    var sortOrder: Int = 0

    @Attribute(.externalStorage)
    var iconData: Data?

    var task: TaskItem?

    init(kind: ShortcutKind, target: String, title: String, task: TaskItem? = nil) {
        self.kind = kind
        self.target = target
        self.title = title
        self.task = task
    }
}
