//
//  BoardDetailView.swift
//  Simplr
//

import SwiftUI
import SwiftData

struct BoardDetailView: View {
    @Bindable var board: Board
    @State private var showingAddTask = false

    var body: some View {
        Group {
            switch board.preferredView {
            case .list:
                BoardListView(board: board)
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
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddTask = true
                } label: {
                    Label("New Task", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(board: board)
        }
    }
}

struct BoardListView: View {
    let board: Board

    var body: some View {
        // TODO(F-3): empty state for a board without tasks
        List(board.sortedTasks, id: \.id) { task in
            TaskWidget(task: task)
                .listRowSeparator(.hidden)
        }
    }
}

#Preview {
    NavigationStack {
        BoardDetailView(board: PreviewData.sampleTask.board!)
    }
    .modelContainer(PreviewData.container)
}
