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
    @State private var draftProgress: Double = 0
    @State private var isAdjusting = false

    private var displayProgress: Double {
        isAdjusting ? draftProgress : task.progress
    }

    private var tint: Color { task.tint(at: displayProgress) }

    /// Dragging writes to a local draft; SwiftData is updated once on release
    /// so the row doesn't jump between status sections mid-drag.
    private var progressBinding: Binding<Double> {
        Binding(
            get: { displayProgress },
            set: { newValue in
                if isAdjusting {
                    draftProgress = newValue
                } else {
                    task.setProgress(newValue)
                }
            }
        )
    }

    var body: some View {
        ZStack(alignment: .leading) {
            Color.gray.opacity(0.1)

            GlassProgressFill(progress: displayProgress, tint: tint, isActive: isAdjusting)

            if let category = task.category {
                category.color
                    .frame(width: 4)
            }

            VStack(alignment: .leading, spacing: 4) {
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
                }.padding(.horizontal, 10)

                GlassProgressSlider(value: progressBinding, tint: tint) { editing in
                    if editing {
                        draftProgress = task.progress
                        isAdjusting = true
                    } else {
                        isAdjusting = false
                        task.setProgress(draftProgress)
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 6, trailing: 10))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
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
