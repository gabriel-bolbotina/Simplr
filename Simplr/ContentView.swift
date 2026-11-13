//
//  ContentView.swift
//  Simplr
//
//  Created by Gabriel Bolbotina on 27.08.2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Board.sortOrder) private var boards: [Board]
    @State private var selection: Board?

    var body: some View {
        NavigationSplitView {
            SidebarView(boards: boards, selection: $selection)
                .navigationSplitViewColumnWidth(min: 180, ideal: 220)
        } detail: {
            if let selection {
                BoardDetailView(board: selection)
            } else {
                // TODO(F-3): empty state for "no board selected"
                Text("Select a board")
            }
        }
        .onAppear(perform: ensureDefaultBoard)
    }

    private func ensureDefaultBoard() {
        if boards.isEmpty {
            let inbox = Board(name: "Inbox", symbol: "tray")
            modelContext.insert(inbox)
            selection = inbox
        } else if selection == nil {
            selection = boards.first
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewData.container)
}
