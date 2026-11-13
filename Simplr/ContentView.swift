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
    @Query private var tasks: [TaskObject]
    @State private var showingAddTask = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("Here are today's tasks")
                .font(.title.bold())
                .multilineTextAlignment(.leading)
                .padding(.leading)
                .foregroundStyle(.blue.opacity(0.9))
            Spacer()
            List(tasks) { task in
                TaskWidget(task: task)
                    .listRowSeparator(.hidden)
            }
            .cornerRadius(10)
            HStack {
                Spacer()
                Button(action: {
                    showingAddTask = true
                }) {
                    Text("Add task")
                }
            }.padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 10))
        }
        .padding()
        .sheet(isPresented: $showingAddTask) {
            AddTaskView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TaskObject.self, inMemory: true)
}
