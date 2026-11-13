//
//  KanbanView.swift
//  Simplr
//

import SwiftUI
import UniformTypeIdentifiers

/// What gets dragged when a card moves between columns.
struct TaskDragItem: Codable, Transferable {
    let id: UUID

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}

struct KanbanView: View {
    let board: Board
    @Binding var selection: UUID?
    let actions: TaskActions

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ForEach(TaskStatus.allCases, id: \.self) { status in
                KanbanColumn(
                    status: status,
                    tasks: board.sortedTasks.filter { $0.status == status },
                    selection: $selection,
                    actions: actions
                ) { items, target in
                    drop(items, into: status, before: target)
                }
            }
        }
        .padding()
        // Lets ⌫ (onDeleteCommand on the board) reach the selected card.
        .focusable()
        .focusEffectDisabled()
    }

    private func drop(_ items: [TaskDragItem], into status: TaskStatus, before target: TaskItem?) -> Bool {
        guard let id = items.first?.id, let task = board.tasks?.first(where: { $0.id == id }) else {
            return false
        }
        withAnimation(.snappy) {
            board.place(task, in: status, before: target)
        }
        selection = id
        return true
    }
}

struct KanbanColumn: View {
    let status: TaskStatus
    let tasks: [TaskItem]
    @Binding var selection: UUID?
    let actions: TaskActions
    /// Called with the dropped items and the card they were dropped on (nil = end of column).
    let onDrop: ([TaskDragItem], TaskItem?) -> Bool

    @State private var isTargeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(status.title, systemImage: status.symbol)
                    .font(.headline)
                Text("\(tasks.count)")
                    .foregroundStyle(.tertiary)
                Spacer()
            }
            .padding(.horizontal, 6)

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(tasks, id: \.id) { task in
                        KanbanCard(task: task, isSelected: selection == task.id)
                            .onTapGesture(count: 2) { actions.edit(task) }
                            .simultaneousGesture(TapGesture().onEnded { selection = task.id })
                            .contextMenu { TaskContextMenu(task: task, actions: actions) }
                            .draggable(TaskDragItem(id: task.id)) {
                                KanbanCard(task: task, isSelected: false)
                                    .frame(width: 240)
                            }
                            .dropDestination(for: TaskDragItem.self) { items, _ in
                                _ = onDrop(items, task)
                            }
                    }
                }
                .padding(4)
            }
            .overlay {
                if tasks.isEmpty {
                    Text(isTargeted ? "Drop here" : "No tasks")
                        .font(.callout)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.accentColor.opacity(isTargeted ? 0.6 : 0), lineWidth: 2)
        }
        .dropDestination(for: TaskDragItem.self) { items, _ in
            onDrop(items, nil)
        } isTargeted: { targeted in
            withAnimation(.easeOut(duration: 0.15)) { isTargeted = targeted }
        }
    }
}

struct KanbanCard: View {
    let task: TaskItem
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(task.title)
                    .font(.headline)
                    .lineLimit(3)
                    .foregroundStyle(task.status == .done ? .secondary : .primary)
                Spacer(minLength: 4)
                Image(systemName: "flag.fill")
                    .font(.caption)
                    .foregroundStyle(task.priority.color)
                    .help("\(task.priority.rawValue) priority")
            }

            if !task.notes.isEmpty {
                Text(task.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            ProgressView(value: task.progress)
                .tint(task.category?.color ?? .accentColor)

            HStack(spacing: 8) {
                if let category = task.category {
                    Label(category.name, systemImage: "circle.fill")
                        .foregroundStyle(category.color)
                }
                Spacer(minLength: 0)
                if let days = task.remainingDays {
                    Text(days < 0 ? "\(abs(days))d overdue" : "\(days)d left")
                        .foregroundStyle(days < 0 ? .red : .secondary)
                }
                ShortcutIcons(shortcuts: task.shortcuts ?? [])
            }
            .font(.caption)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 2)
        }
        .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
        .contentShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    KanbanView(
        board: PreviewData.sampleTask.board!,
        selection: .constant(nil),
        actions: TaskActions(newTask: {}, edit: { _ in }, delete: { _ in })
    )
    .frame(width: 900, height: 500)
    .modelContainer(PreviewData.container)
}
