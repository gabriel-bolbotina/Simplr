//
//  Category.swift
//  Simplr
//

import Foundation
import SwiftData

enum CategoryPattern: String, Codable, CaseIterable {
    case none
    case stripes
    case dots
    case waves
}

@Model
final class Category {
    var id: UUID = UUID()
    var name: String = ""
    var colorHex: String = "#0A84FF"
    var pattern: CategoryPattern = CategoryPattern.none

    @Relationship(deleteRule: .nullify, inverse: \TaskItem.category)
    var tasks: [TaskItem]? = []

    init(name: String, colorHex: String = "#0A84FF", pattern: CategoryPattern = .none) {
        self.name = name
        self.colorHex = colorHex
        self.pattern = pattern
    }
}
