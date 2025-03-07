//
//  ContentView.swift
//  new_swift_app
//
//  Created by Gabriel Bolbotina on 27.08.2024.
//
//new thing

import SwiftUI

struct ContentView: View {
  @State private var counter: Int = 0
  @State private var dued: Bool = false
  @State private var task_list: [TaskObject] = [
    TaskObject(title: "Go get some omelette", description: "vegan of course", dueDate: "12.03.2025", priority: Priority.low),
    TaskObject(title: "Do laundry", description: "clean your room asap", dueDate: "12.03.2025", priority: Priority.low),
    TaskObject(title: "go check what needs to be done", description: "vegan of course", dueDate: "12.03.2025", priority: Priority.low),
    TaskObject(title: "Go get some omelette", description: "vegan of course", dueDate: "12.03.2025", priority: Priority.low),
    ]
  var body: some View {
    VStack(alignment: .leading) {
      Text("Here are today's tasks").font(.title.bold()).multilineTextAlignment(.leading).padding(.leading).foregroundStyle(.blue.opacity(0.9)).padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
      Spacer()
      List(task_list)
      {
        task in TaskWidget(tasks: task).listRowSeparator(.hidden)
      }.cornerRadius(10)
      HStack {
        Spacer() // Pushes the button to the right
        Button(action: {
          addTask()
        }) {
          Text("Add task")
        }
      }.padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 10))
    }.padding().background(Color.white)

  }
  
  private func addTask() {
    task_list.append(TaskObject(title: "New task", description: " ", dueDate: "12.03.2025", priority: Priority.low))
  }
}


#Preview {
    ContentView()
}
