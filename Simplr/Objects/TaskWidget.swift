//
//  TaskWidget.swift
//  Simplr
//
//  Created by Gabriel Bolbotina on 04.03.2025.
//

import SwiftUI
import SwiftData

struct TaskWidget: View {
    @Bindable var task: TaskItem
    @State private var isEditing = false
    @State private var localProgress: Double
    @State private var cardWidth: CGFloat = 300
    @State private var holdWork: DispatchWorkItem?

    init(task: TaskItem) {
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

            if let category = task.category {
                category.color
                    .frame(width: 4)
            }

            VStack(alignment: .leading) {
                HStack {
                    Text(task.title).font(.title2).multilineTextAlignment(.leading)
                        .foregroundStyle(task.status == .done ? .secondary : .primary)
                    Text(task.priority.rawValue).font(.title3.bold()).foregroundStyle(task.priority.color)
                    Spacer(minLength: 8)
                    ShortcutIcons(shortcuts: task.shortcuts ?? [])
                }.padding(EdgeInsets(top: 5, leading: 10, bottom: 0, trailing: 10))

                HStack {
                    Text(task.notes).font(.caption)
                        .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
                    Spacer(minLength: 1)
                    if let days = task.remainingDays {
                        if days < 0 {
                            Text("\(abs(days)) days due").font(.subheadline).foregroundStyle(.red)
                        } else {
                            Text("\(days) days remaining").font(.subheadline).foregroundStyle(.gray)
                        }
                    }
                }.padding(EdgeInsets(top: 0, leading: 10, bottom: 8, trailing: 10))
            }
            .opacity(isEditing ? 0 : 1)
            .animation(.easeInOut(duration: 0.2), value: isEditing)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { cardWidth = $0 }
        .simultaneousGesture(
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
                        task.setProgress(localProgress)
                        withAnimation(.easeInOut(duration: 0.2)) { isEditing = false }
                    }
                }
        )
    }
}

/// Small icons for a task's shortcuts. Real app icons and favicons arrive with S-1/S-2.
struct ShortcutIcons: View {
    let shortcuts: [Shortcut]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(shortcuts.sorted { $0.sortOrder < $1.sortOrder }, id: \.id) { shortcut in
                Image(systemName: shortcut.kind == .url ? "globe" : "app.dashed")
                    .foregroundStyle(.secondary)
                    .help(shortcut.title)
            }
        }
    }
}
