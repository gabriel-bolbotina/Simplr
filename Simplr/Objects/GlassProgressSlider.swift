//
//  GlassProgressSlider.swift
//  Simplr
//

import SwiftUI

/// A progress slider with a Liquid Glass thumb that stretches with drag
/// velocity, settles with a spring, and morphs a percentage bubble out of
/// itself while dragging. Crossing quarter marks plays trackpad haptics.
struct GlassProgressSlider: View {
    @Binding var value: Double
    var tint: Color = .accentColor
    var onEditingChanged: (Bool) -> Void = { _ in }

    @State private var isDragging = false
    @State private var stretch: CGFloat = 0
    @Namespace private var glassNamespace

    private let thumbSize: CGFloat = 22
    private let trackHeight: CGFloat = 6

    var body: some View {
        GeometryReader { geo in
            let usable = max(geo.size.width - thumbSize, 1)
            let x = thumbSize / 2 + usable * value
            let midY = geo.size.height / 2

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.quaternary)
                    .frame(height: trackHeight)
                Capsule()
                    .fill(tint.gradient)
                    .frame(width: x, height: trackHeight)

                GlassEffectContainer(spacing: 10) {
                    ZStack {
                        thumb
                            .position(x: x, y: midY)
                        if isDragging {
                            percentBubble
                                .position(x: bubbleX(thumbX: x, width: geo.size.width), y: midY)
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .contentShape(Rectangle())
            .gesture(drag(usable: usable))
        }
        .frame(height: 28)
        .focusable()
        .focusEffectDisabled()
        .onKeyPress(.leftArrow) { step(by: -0.05) }
        .onKeyPress(.rightArrow) { step(by: 0.05) }
        .accessibilityRepresentation {
            Slider(value: $value, in: 0...1) {
                Text("Progress")
            } onEditingChanged: { onEditingChanged($0) }
        }
    }

    private var thumb: some View {
        let grow: CGFloat = isDragging ? 1.2 : 1
        let isComplete = value >= 1
        return Color.clear
            .frame(
                width: thumbSize * grow * (1 + abs(stretch) * 0.7),
                height: thumbSize * grow * (1 - abs(stretch) * 0.25)
            )
            .overlay {
                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .glassEffect(.regular.tint(tint.opacity(isComplete ? 0.8 : 0.3)).interactive(), in: Capsule())
            .glassEffectID("thumb", in: glassNamespace)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isComplete)
    }

    /// Values this close to either end snap to it, so finishing a task is easy to hit.
    nonisolated static let snapDistance = 0.03

    nonisolated static func snapped(_ value: Double) -> Double {
        let clamped = min(max(value, 0), 1)
        if clamped >= 1 - snapDistance { return 1 }
        if clamped <= snapDistance { return 0 }
        return clamped
    }

    private var percentBubble: some View {
        Text(value, format: .percent.precision(.fractionLength(0)))
            .font(.caption.monospacedDigit().weight(.semibold))
            .padding(.horizontal, 8)
            .frame(height: thumbSize)
            .glassEffect(.regular.tint(tint.opacity(0.2)), in: Capsule())
            .glassEffectID("percent", in: glassNamespace)
    }

    /// Keeps the bubble beside the thumb, flipping to the left near the end of the track.
    private func bubbleX(thumbX: CGFloat, width: CGFloat) -> CGFloat {
        let offset = thumbSize + 22
        return thumbX + offset < width - 20 ? thumbX + offset : thumbX - offset
    }

    private func drag(usable: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { gesture in
                if !isDragging {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { isDragging = true }
                    onEditingChanged(true)
                }
                let newValue = Self.snapped((gesture.location.x - thumbSize / 2) / usable)
                ProgressHaptics.play(from: value, to: newValue)
                value = newValue
                withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.6)) {
                    stretch = min(max(gesture.velocity.width / 1600, -1), 1)
                }
            }
            .onEnded { _ in
                withAnimation(.spring(response: 0.45, dampingFraction: 0.45)) {
                    stretch = 0
                    isDragging = false
                }
                onEditingChanged(false)
            }
    }

    private func step(by delta: Double) -> KeyPress.Result {
        onEditingChanged(true)
        let newValue = Self.snapped(value + delta)
        ProgressHaptics.play(from: value, to: newValue)
        withAnimation(.snappy) { value = newValue }
        onEditingChanged(false)
        return .handled
    }
}

#Preview {
    @Previewable @State var progress = 0.4
    GlassProgressSlider(value: $progress, tint: .blue)
        .padding()
        .frame(width: 360)
}
