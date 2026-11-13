//
//  BoardDetailView.swift
//  Simplr
//

import SwiftUI
import SwiftData

struct BoardDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var board: Board

    @State private var selectedTaskID: UUID?
    @State private var showingNewTask = false
    @State private var editingTask: EditingTask?
    @State private var taskToDelete: TaskItem?

    var body: some View {
        Group {
            switch board.preferredView {
            case .list:
                BoardListView(board: board, selection: $selectedTaskID, actions: actions)
            case .kanban:
                ContentUnavailableView(
                    "Kanban is coming",
                    systemImage: "rectangle.split.3x1",
                    description: Text("Tracked in B-4.")
                )
            }
        }
        .navigationTitle(board.name)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("View", selection: $board.preferredView) {
                    Label("List", systemImage: "list.bullet").tag(BoardViewMode.list)
                    Label("Kanban", systemImage: "rectangle.split.3x1").tag(BoardViewMode.kanban)
                }
                .pickerStyle(.segmented)
            }
            ToolbarSpacer(.flexible)
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewTask = true
                } label: {
                    Label("New Task", systemImage: "plus")
                }
                .buttonStyle(.glassProminent)
                .help("New Task (⌘N)")
            }
        }
        .focusedSceneValue(\.newTaskAction, FocusedAction(id: board.id.uuidString) { showingNewTask = true })
        .onDeleteCommand {
            if let task = task(withID: selectedTaskID) { taskToDelete = task }
        }
        .sheet(isPresented: $showingNewTask) {
            TaskEditorView(board: board)
        }
        .sheet(item: $editingTask) { editing in
            TaskEditorView(board: board, task: task(withID: editing.id))
        }
        .confirmationDialog(
            "Delete “\(taskToDelete?.title ?? "")”?",
            isPresented: Binding(get: { taskToDelete != nil }, set: { if !$0 { taskToDelete = nil } }),
            presenting: taskToDelete
        ) { task in
            Button("Delete Task", role: .destructive) { delete(task) }
        } message: { _ in
            Text("This can't be undone.")
        }
        .onChange(of: board) { selectedTaskID = nil }
    }

    private var actions: TaskActions {
        TaskActions(
            newTask: { showingNewTask = true },
            edit: { editingTask = EditingTask(id: $0.id) },
            delete: { taskToDelete = $0 }
        )
    }

    private func task(withID id: UUID?) -> TaskItem? {
        guard let id else { return nil }
        return board.tasks?.first { $0.id == id }
    }

    private func delete(_ task: TaskItem) {
        if selectedTaskID == task.id { selectedTaskID = nil }
        modelContext.delete(task)
        taskToDelete = nil
    }
}

/// What a task row or card can ask its board to do.
struct TaskActions {
    var newTask: () -> Void
    var edit: (TaskItem) -> Void
    var delete: (TaskItem) -> Void
}

struct TaskContextMenu: View {
    let task: TaskItem
    let actions: TaskActions

    var body: some View {
        Button("Edit…") { actions.edit(task) }
        Divider()
        Button("Delete…", role: .destructive) { actions.delete(task) }
    }
}

struct BoardListView: View {
    let board: Board
    @Binding var selection: UUID?
    let actions: TaskActions

    var body: some View {
        if board.sortedTasks.isEmpty {
            ContentUnavailableView {
                Label("No Tasks Yet", systemImage: "checklist")
            } description: {
                Text("Add your first task to \(board.name).")
            } actions: {
                Button("New Task", action: actions.newTask)
                    .buttonStyle(.glassProminent)
            }
        } else {
            List(selection: $selection) {
                ForEach(TaskStatus.allCases, id: \.self) { status in
                    let tasks = board.sortedTasks.filter { $0.status == status }
                    if !tasks.isEmpty {
                        Section {
                            ForEach(tasks, id: \.id) { task in
                                TaskWidget(task: task)
                                    .listRowSeparator(.hidden)
                                    .tag(task.id)
                            }
                        } header: {
                            HStack {
                                Label(status.title, systemImage: status.symbol)
                                Text("\(tasks.count)").foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
            }
            .animation(.default, value: board.sortedTasks.map(\.status))
            .contextMenu(forSelectionType: UUID.self) { ids in
                if let task = board.tasks?.first(where: { ids.contains($0.id) }) {
                    TaskContextMenu(task: task, actions: actions)
                }
            } primaryAction: { ids in
                if let task = board.tasks?.first(where: { ids.contains($0.id) }) {
                    actions.edit(task)
                }
            }
        }
    }
}

private struct EditingTask: Identifiable {
    let id: UUID
}

#Preview {
    NavigationStack {
        BoardDetailView(board: PreviewData.sampleTask.board!)
    }
    .modelContainer(PreviewData.container)
}
