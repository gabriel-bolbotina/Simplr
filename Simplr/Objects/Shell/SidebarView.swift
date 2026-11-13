//
//  SidebarView.swift
//  Simplr
//

import SwiftUI
import SwiftData

struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext
    let boards: [Board]
    @Binding var selection: Board?

    @State private var renamingBoard: Board?
    @State private var boardToDelete: Board?
    @FocusState private var renameFieldFocused: Bool

    var body: some View {
        Group {
            if boards.isEmpty {
                ContentUnavailableView {
                    Label("No Boards", systemImage: "square.stack")
                } description: {
                    Text("Create a board to start adding tasks.")
                } actions: {
                    Button("New Board", action: addBoard)
                }
            } else {
                List(selection: $selection) {
                    Section("Boards") {
                        ForEach(boards) { board in
                            row(for: board)
                                .tag(board)
                                .contextMenu {
                                    Button("Rename") { renamingBoard = board }
                                    Divider()
                                    Button("Delete…", role: .destructive) { boardToDelete = board }
                                }
                        }
                        .onMove(perform: moveBoards)
                    }
                }
                .onDeleteCommand { boardToDelete = selection }
            }
        }
        .navigationTitle("Simplr")
        .toolbar {
            ToolbarItem {
                Button(action: addBoard) {
                    Label("New Board", systemImage: "plus.rectangle.on.rectangle")
                }
                .help("New Board")
            }
        }
        .confirmationDialog(
            "Delete “\(boardToDelete?.name ?? "")”?",
            isPresented: Binding(get: { boardToDelete != nil }, set: { if !$0 { boardToDelete = nil } }),
            presenting: boardToDelete
        ) { board in
            Button("Delete Board", role: .destructive) { delete(board) }
        } message: { board in
            Text("Its \(board.tasks?.count ?? 0) tasks will be deleted too. This can't be undone.")
        }
    }

    @ViewBuilder
    private func row(for board: Board) -> some View {
        if renamingBoard == board {
            TextField("Board name", text: Bindable(board).name)
                .focused($renameFieldFocused)
                .onSubmit(finishRenaming)
                .onAppear { renameFieldFocused = true }
                .onChange(of: renameFieldFocused) { _, focused in
                    if !focused { finishRenaming() }
                }
        } else {
            Label(board.name, systemImage: board.symbol)
        }
    }

    private func addBoard() {
        let board = Board(name: "New Board", sortOrder: (boards.map(\.sortOrder).max() ?? -1) + 1)
        modelContext.insert(board)
        selection = board
        renamingBoard = board
    }

    private func finishRenaming() {
        guard let board = renamingBoard else { return }
        let trimmed = board.name.trimmingCharacters(in: .whitespacesAndNewlines)
        board.name = trimmed.isEmpty ? "Untitled" : trimmed
        renamingBoard = nil
    }

    private func moveBoards(from source: IndexSet, to destination: Int) {
        var ordered = boards
        ordered.move(fromOffsets: source, toOffset: destination)
        for (index, board) in ordered.enumerated() {
            board.sortOrder = index
        }
    }

    private func delete(_ board: Board) {
        if selection == board {
            selection = boards.first { $0 != board }
        }
        modelContext.delete(board)
        boardToDelete = nil
    }
}
