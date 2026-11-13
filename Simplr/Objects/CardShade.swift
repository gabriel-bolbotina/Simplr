//
//  CardShade.swift
//  Simplr
//

import SwiftUI

/// A soft background shade in the category colour, with the category's
/// pattern as a faint texture. Neutral grey for tasks without a category.
struct CardShade: View {
    var category: Category?

    var body: some View {
        ZStack {
            (category?.color ?? .gray).opacity(category == nil ? 0.1 : 0.12)
            if let category, category.pattern != .none {
                CategoryPatternView(pattern: category.pattern, color: category.color.opacity(0.12))
            }
        }
        .allowsHitTesting(false)
    }
}

extension TaskItem {
    /// Category colour if there is one, otherwise blue → orange → green by progress.
    func tint(at progress: Double) -> Color {
        if let category { return category.color }
        switch progress {
        case 0..<0.34: return .blue
        case 0.34..<0.67: return .orange
        default: return .green
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(CategoryPattern.allCases, id: \.self) { pattern in
            CardShade(category: Category(name: pattern.title, colorHex: "#BF5AF2", pattern: pattern))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(height: 50)
        }
        CardShade(category: nil)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .frame(height: 50)
    }
    .padding()
    .frame(width: 400)
}
