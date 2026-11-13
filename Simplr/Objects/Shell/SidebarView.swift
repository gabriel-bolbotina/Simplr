//
//  SidebarView.swift
//  Simplr
//

import SwiftUI

struct SidebarView: View {
    let boards: [Board]
    @Binding var selection: Board?

    var body: some View {
        List(selection: $selection) {
            Section("Boards") {
                ForEach(boards) { board in
                    Label(board.name, systemImage: board.symbol)
                        .tag(board)
                }
            }
        }
        .navigationTitle("Simplr")
    }
}
