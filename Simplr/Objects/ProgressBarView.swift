//
//  ProgressBarView.swift
//  Simplr
//
//  Created by Gabriel Bolbotina on 22.04.2026.
//

import SwiftUI

struct ProgressBarView: View {
    @Binding var progress: Double
    @State private var isActive = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: isActive ? 16 : 10)

                // Filled portion
                RoundedRectangle(cornerRadius: 6)
                    .fill(fillColor)
                    .frame(width: geometry.size.width * progress, height: isActive ? 16 : 10)
                    .animation(.easeOut(duration: 0.08), value: progress)

                // Thumb indicator
                Circle()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
                    .frame(width: isActive ? 22 : 0, height: isActive ? 22 : 0)
                    .offset(x: max(0, geometry.size.width * progress - (isActive ? 11 : 0)))
                    .animation(.spring(response: 0.2), value: isActive)
            }
            .frame(height: 22)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isActive = true
                        let raw = value.location.x / geometry.size.width
                        progress = max(0, min(1, raw))
                    }
                    .onEnded { _ in
                        isActive = false
                    }
            )
        }
        .frame(height: 22)
        .animation(.spring(response: 0.2), value: isActive)
    }

    private var fillColor: Color {
        switch progress {
        case 0..<0.34: return .blue
        case 0.34..<0.67: return .orange
        default: return .green
        }
    }
}

#Preview {
    @Previewable @State var progress = 0.4
    ProgressBarView(progress: $progress)
        .padding()
}
