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
    @AppStorage("didCreateInbox") private var didCreateInbox = false

    var body: some View {
        NavigationSplitView {
            SidebarView(boards: boards, selection: $selection)
                .navigationSplitViewColumnWidth(min: 180, ideal: 220)
        } detail: {
            if let selection {
                BoardDetailView(board: selection)
            } else {
                ContentUnavailableView(
                    "No Board Selected",
                    systemImage: "sidebar.left",
                    description: Text("Pick a board in the sidebar to see its tasks.")
                )
            }
        }
        .onAppear(perform: ensureDefaultBoard)
    }

    private func ensureDefaultBoard() {
        // Only seed once, so deleting every board leaves the empty state instead.
        if boards.isEmpty && !didCreateInbox {
            let inbox = Board(name: "Inbox", symbol: "tray")
            modelContext.insert(inbox)
            selection = inbox
        } else if selection == nil {
            selection = boards.first
        }
        didCreateInbox = true
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewData.container)
}
