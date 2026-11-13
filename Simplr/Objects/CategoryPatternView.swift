//
//  CategoryPatternView.swift
//  Simplr
//

import SwiftUI

/// Draws a category's pattern (stripes, dots or waves) to layer inside the glass fill.
struct CategoryPatternView: View {
    var pattern: CategoryPattern
    var color: Color
    var spacing: CGFloat = 8

    var body: some View {
        Canvas { context, size in
            let shading = GraphicsContext.Shading.color(color)
            switch pattern {
            case .none:
                break
            case .stripes:
                var path = Path()
                var x = -size.height
                while x < size.width {
                    path.move(to: CGPoint(x: x, y: size.height))
                    path.addLine(to: CGPoint(x: x + size.height, y: 0))
                    x += spacing
                }
                context.stroke(path, with: shading, lineWidth: 2)
            case .dots:
                var y = spacing / 2
                while y < size.height {
                    var x = spacing / 2
                    while x < size.width {
                        context.fill(Path(ellipseIn: CGRect(x: x - 1.5, y: y - 1.5, width: 3, height: 3)), with: shading)
                        x += spacing
                    }
                    y += spacing
                }
            case .waves:
                var path = Path()
                var y = spacing / 2
                while y < size.height + spacing {
                    path.move(to: CGPoint(x: 0, y: y))
                    var x: CGFloat = 0
                    while x <= size.width {
                        x += 2
                        path.addLine(to: CGPoint(x: x, y: y + sin(x / spacing * .pi) * 2))
                    }
                    y += spacing
                }
                context.stroke(path, with: shading, lineWidth: 1.5)
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    HStack {
        ForEach(CategoryPattern.allCases, id: \.self) { pattern in
            CategoryPatternView(pattern: pattern, color: .purple.opacity(0.5))
                .frame(width: 80, height: 50)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
        }
    }
    .padding()
}
