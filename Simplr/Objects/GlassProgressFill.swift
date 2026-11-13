//
//  GlassProgressFill.swift
//  Simplr
//

import SwiftUI

/// Tinted Liquid Glass that fills a card from the leading edge as progress grows.
struct GlassProgressFill: View {
    var progress: Double
    var tint: Color
    var pattern: CategoryPattern = .none
    var isActive: Bool = false
    var cornerRadius: CGFloat = 10

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width * progress
            let trailingRadius = width >= geo.size.width - 1 ? cornerRadius : 4
            let shape = UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius,
                bottomLeadingRadius: cornerRadius,
                bottomTrailingRadius: trailingRadius,
                topTrailingRadius: trailingRadius
            )
            Color.clear
                .frame(width: width, height: geo.size.height)
                .overlay {
                    CategoryPatternView(pattern: pattern, color: tint.opacity(0.35))
                        .clipShape(shape)
                }
                .glassEffect(.regular.tint(tint.opacity(isActive ? 0.55 : 0.35)), in: shape)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: progress)
        .animation(.easeInOut(duration: 0.2), value: isActive)
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
        ForEach([0.0, 0.3, 0.7, 1.0], id: \.self) { progress in
            RoundedRectangle(cornerRadius: 10)
                .fill(.quaternary)
                .overlay { GlassProgressFill(progress: progress, tint: .purple) }
                .frame(height: 50)
        }
    }
    .padding()
    .frame(width: 400)
}
