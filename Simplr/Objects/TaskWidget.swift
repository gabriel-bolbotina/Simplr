//
//  TaskWidget.swift
//  Simplr
//
//  Created by Gabriel Bolbotina on 04.03.2025.
//

import SwiftUI
import SwiftData

struct TaskWidget: View {
    @Bindable var task: TaskObject
    @State private var isEditing = false
    @State private var localProgress: Double
    @State private var cardWidth: CGFloat = 300
    @State private var holdWork: DispatchWorkItem?

    init(task: TaskObject) {
        self.task = task
        self._localProgress = State(initialValue: task.progress)
    }

    private var displayProgress: Double {
        isEditing ? localProgress : task.progress
    }

    private var fillColor: Color {
        switch displayProgress {
        case 0..<0.34: return .blue
        case 0.34..<0.67: return .orange
        default: return .green
        }
    }

    var body: some View {
        ZStack(alignment: .leading) {
            Color.gray.opacity(0.1)

            fillColor
                .opacity(isEditing ? 0.45 : 0.18)
                .frame(width: cardWidth * displayProgress)
                .animation(.easeInOut(duration: 0.25), value: isEditing)

            VStack(alignment: .leading) {
                HStack {
                    Text(task.title).font(.title2).multilineTextAlignment(.leading)
                    Text(task.getPriority()).font(.title3.bold()).foregroundStyle(.red)
                }.padding(EdgeInsets(top: 5, leading: 10, bottom: 0, trailing: 10))

                let days = task.getRemainingDays()
                HStack {
                    Text(task.taskDescription).font(.caption)
                        .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
                    Spacer(minLength: 1)
                    if days < 0 {
                        Text("\(abs(days)) days due").font(.subheadline).foregroundStyle(.red)
                    } else {
                        Text("\(days) days remaining").font(.subheadline).foregroundStyle(.gray)
                    }
                }.padding(EdgeInsets(top: 0, leading: 10, bottom: 8, trailing: 10))
            }
            .opacity(isEditing ? 0 : 1)
            .animation(.easeInOut(duration: 0.2), value: isEditing)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .background(
            GeometryReader { geo in
                Color.clear.onAppear { cardWidth = geo.size.width }
            }
        )
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { value in
                    if isEditing {
                        // Already in edit mode — update local buffer, no SwiftData write yet
                        localProgress = max(0, min(1, value.location.x / cardWidth))
                    } else if holdWork == nil {
                        // First touch — schedule hold activation after 0.35 s
                        let work = DispatchWorkItem {
                            localProgress = task.progress
                            withAnimation(.easeInOut(duration: 0.2)) { isEditing = true }
                        }
                        holdWork = work
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: work)
                    }
                }
                .onEnded { _ in
                    holdWork?.cancel()
                    holdWork = nil
                    if isEditing {
                        // Single SwiftData write on release
                        task.progress = localProgress
                        withAnimation(.easeInOut(duration: 0.2)) { isEditing = false }
                    }
                }
        )
    }
}
