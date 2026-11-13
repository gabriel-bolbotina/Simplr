//
//  Styling.swift
//  Simplr
//

import AppKit
import SwiftUI

extension Priority {
    var color: Color {
        switch self {
        case .low:    return .green
        case .medium: return .orange
        case .high:   return .red
        }
    }
}

extension TaskStatus {
    var title: String {
        switch self {
        case .todo:       return "To Do"
        case .inProgress: return "In Progress"
        case .done:       return "Done"
        }
    }

    var symbol: String {
        switch self {
        case .todo:       return "circle"
        case .inProgress: return "circle.lefthalf.filled"
        case .done:       return "checkmark.circle.fill"
        }
    }
}

extension Category {
    var color: Color { Color(hex: colorHex) ?? .accentColor }
}

extension CategoryPattern {
    var title: String {
        switch self {
        case .none:    return "None"
        case .stripes: return "Stripes"
        case .dots:    return "Dots"
        case .waves:   return "Waves"
        }
    }
}

extension Color {
    /// Parses "#RRGGBB" or "RRGGBB".
    init?(hex: String) {
        let digits = hex.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "#", with: "")
        guard digits.count == 6, let value = UInt32(digits, radix: 16) else { return nil }
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}

extension Color {
    /// "#RRGGBB" in sRGB, or nil if the colour can't be converted.
    var hexString: String? {
        guard let rgb = NSColor(self).usingColorSpace(.sRGB) else { return nil }
        func byte(_ component: CGFloat) -> Int { Int((min(max(component, 0), 1) * 255).rounded()) }
        return String(format: "#%02X%02X%02X", byte(rgb.redComponent), byte(rgb.greenComponent), byte(rgb.blueComponent))
    }
}
