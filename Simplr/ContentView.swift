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
    VStack {
      List(task_list)
      {
        task in TaskWidget(tasks: task)
      }
      Button(action: {addTask()})
      {
        Text("Add task");
      }
    }.padding(0.7)
  }
  
  private func addTask() {
    task_list.append(TaskObject(title: "New task", description: " ", dueDate: "12.03.2025", priority: Priority.low))
  }
}


#Preview {
    ContentView()
}
